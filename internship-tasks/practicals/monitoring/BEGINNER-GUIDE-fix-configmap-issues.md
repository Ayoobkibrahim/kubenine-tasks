# Beginner Guide: Fix Grafana ConfigMap Problems on Our Cluster

**Read this first** if you are new to Kubernetes, Helm, or Grafana.

**Harder / full details:** [ARCHITECTURE-configmap-to-pod.md](./ARCHITECTURE-configmap-to-pod.md) (diagrams) · [TROUBLESHOOTING-configmap-and-grafana.md](./TROUBLESHOOTING-configmap-and-grafana.md) (everything)

**Your namespace:** `ayoob-monitoring`  
**Your Grafana release:** `ayoob-prometheus-stack`

---

## What happened? (simple story)

1. You installed monitoring with **Helm** (Prometheus + Grafana).
2. Grafana pod stayed stuck: **ContainerCreating** (not Running).
3. Error said: **ConfigMap not found** — but `kubectl get configmap` showed the ConfigMap **exists**.
4. On our **shared school cluster**, the node (kubelet) could not mount ConfigMaps into new pods — only **Secrets** worked.
5. We fixed Grafana by putting config in a **Secret** and patching the Deployment.
6. Dashboards were empty because the **sidecar** (auto-import) also failed — we **exported JSON files** and imported them in Grafana UI.
7. We installed **Loki** separately for logs (Task 2.54).

You did nothing wrong. The cluster had platform issues + many students sharing the same nodes.

---

## Words you need to know

| Word | Simple meaning |
|------|----------------|
| **ConfigMap** | A Kubernetes object that stores config files (like `grafana.ini`) as key/value data |
| **Secret** | Like ConfigMap but for sensitive data; on our cluster it **mounted** when ConfigMap did not |
| **Pod** | One or more containers running on the cluster (e.g. Grafana pod) |
| **kubelet** | Agent on each node that starts pods and mounts volumes |
| **Helm** | Tool that installs charts (packages) like `kube-prometheus-stack` |
| **Volume mount** | Putting a ConfigMap/Secret file **inside** the pod so the app can read it |
| **Sidecar** | Extra container in the same pod (e.g. loads dashboards into Grafana) |
| **Port-forward** | Lets your laptop open `http://localhost:3000` to Grafana in the cluster |

---

## Before you start

Check these on your laptop:

```bash
kubectl get pods -n ayoob-monitoring
kubectl config current-context
```

You should see your cluster context (e.g. `ayoob-k-ibrahim@kubenine`).

Go to the monitoring folder:

```bash
cd ~/KubeNine/internship-tasks/practicals/monitoring
```

---

## Problem 1 — Grafana pod stuck (ConfigMap not found)

### How to know you have this problem

```bash
kubectl get pods -n ayoob-monitoring | grep grafana
```

Bad sign: `ContainerCreating` for a long time (not `Running`).

```bash
kubectl describe pod -n ayoob-monitoring -l app.kubernetes.io/name=grafana
```

Look at **Events** at the bottom. Example:

```text
FailedMount ... configmap "ayoob-prometheus-stack-grafana" not found
```

### Check: does the ConfigMap exist?

```bash
kubectl get configmap ayoob-prometheus-stack-grafana -n ayoob-monitoring
```

- If **NotFound** → go to [Step A](#step-a-helm-created-the-configmap).
- If **NAME exists** but pod still fails → go to [Step B](#step-b-configmap-exists-but-pod-cannot-mount-it-our-main-issue).

---

## Step A — Helm created the ConfigMap

Run Helm upgrade so objects exist in the cluster:

```bash
cd ~/KubeNine/internship-tasks/practicals/monitoring

helm upgrade ayoob-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 85.1.3 \
  --namespace ayoob-monitoring \
  -f ayoob-monitoring-values.yaml
```

Check again:

```bash
kubectl get configmap -n ayoob-monitoring | grep grafana
```

Delete the stuck Grafana pod so Kubernetes tries again:

```bash
kubectl delete pod -n ayoob-monitoring -l app.kubernetes.io/name=grafana
```

Wait 2 minutes. If still `ContainerCreating` with same FailedMount → **Step B**.

---

## Step B — ConfigMap exists but pod cannot mount it (our main issue)

This is what happened on the internship cluster.

| Check | Result on our cluster |
|-------|------------------------|
| `kubectl get configmap` | Works — object exists |
| Pod mount ConfigMap | Fails — "not found" |
| Pod mount Secret | Works |

**Fix:** Copy Grafana config into a **Secret** and tell the Deployment to use the Secret instead of the ConfigMap.

### Step B1 — Copy missing `kube-root-ca.crt` (do this first)

Some namespaces were missing a required ConfigMap:

```bash
kubectl get configmap kube-root-ca.crt -n ayoob-monitoring
```

If **NotFound**, copy from `kube-system`:

```bash
kubectl get configmap kube-root-ca.crt -n kube-system -o yaml \
  | sed 's/namespace: kube-system/namespace: ayoob-monitoring/' \
  | grep -v 'resourceVersion:\|uid:\|creationTimestamp:' \
  | kubectl apply -f -
```

Check:

```bash
kubectl get configmap kube-root-ca.crt -n ayoob-monitoring
```

### Step B2 — Run the fix script (easiest)

We saved the fix in a script:

```bash
cd ~/KubeNine/internship-tasks/practicals/monitoring
chmod +x fix-grafana-secrets.sh
./fix-grafana-secrets.sh
```

**What the script does (in plain English):**

1. Reads `grafana.ini` and `datasources.yaml` from the existing ConfigMap (using kubectl).
2. Creates a Secret named `ayoob-grafana-config-secret` with the same content.
3. Patches the Grafana Deployment to mount the **Secret** instead of the ConfigMap.
4. Deletes the Grafana pod so a new one starts with the Secret mounted.

### Step B3 — Check Grafana is Running

```bash
kubectl get pods -n ayoob-monitoring | grep grafana
```

Good result:

```text
ayoob-prometheus-stack-grafana-xxxxx   1/1   Running   ...
```

### Step B4 — Open Grafana in browser

```bash
kubectl port-forward -n ayoob-monitoring svc/ayoob-prometheus-stack-grafana 3000:80
```

Open: http://localhost:3000  
Login: `admin` / `prom-operator` (unless you changed the password)

### Important: after every `helm upgrade`

Helm may reset volumes back to ConfigMap. Run again:

```bash
./fix-grafana-secrets.sh
```

---

## Problem 2 — Node-exporter pods Pending

### How to know

```bash
kubectl get pods -n ayoob-monitoring | grep node-exporter
```

Status: **Pending**.  
Describe shows: **didn't have free ports** (port 9100 already used by another student).

### Fix — edit `ayoob-monitoring-values.yaml`

Make sure you have:

```yaml
nodeExporter:
  enabled: true

prometheus-node-exporter:
  hostNetwork: false
  hostPID: false
  hostPort: null
```

Then:

```bash
helm upgrade ayoob-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 85.1.3 \
  --namespace ayoob-monitoring \
  -f ayoob-monitoring-values.yaml
```

Check:

```bash
kubectl get pods -n ayoob-monitoring | grep node-exporter
```

Both should be `1/1 Running` (one per node).

---

## Problem 3 — Grafana dashboards page is empty

Grafana runs, but **Dashboards** shows: *You haven't created any dashboards yet.*

### Why

- Helm created ~27 dashboard ConfigMaps in the cluster.
- Normally a **sidecar** container copies them into Grafana automatically.
- On our cluster the sidecar **crashes** (API too slow) and ConfigMap mounts **fail**.
- So we import dashboards **manually**.

### Fix — export dashboard files from cluster

```bash
cd ~/KubeNine/internship-tasks/practicals/monitoring
mkdir -p dashboards

for cm in $(kubectl get cm -n ayoob-monitoring -l grafana_dashboard=1 -o jsonpath='{.items[*].metadata.name}'); do
  kubectl get cm "$cm" -n ayoob-monitoring -o json | python3 -c "
import json, sys
d = json.load(sys.stdin)
key = list(d['data'].keys())[0]
sys.stdout.write(d['data'][key])
" > "dashboards/${cm}.json"
  echo "Saved dashboards/${cm}.json"
done
```

Check files are not empty:

```bash
head -c 50 dashboards/ayoob-prometheus-stack-kub-grafana-overview.json
```

You should see `{"annotations":` not a blank line.

### Fix — import into Grafana (one file in UI)

1. Port-forward Grafana (see above).
2. **Dashboards** → **New** → **Import**.
3. Upload one file from `dashboards/` folder.
4. Choose **Prometheus** as datasource → **Import**.

### Fix — import all 27 at once (script)

Terminal 1:

```bash
kubectl port-forward -n ayoob-monitoring svc/ayoob-prometheus-stack-grafana 3000:80
```

Terminal 2:

```bash
cd ~/KubeNine/internship-tasks/practicals/monitoring
GRAFANA_URL="http://127.0.0.1:3000"
USER="admin"
PASS="prom-operator"

for f in dashboards/*.json; do
  [ ! -s "$f" ] && echo "SKIP empty: $f" && continue
  payload=$(python3 -c "
import json, sys
with open(sys.argv[1], encoding='utf-8') as fh:
    dash = json.load(fh)
print(json.dumps({'dashboard': dash, 'overwrite': True}))
" "$f")
  code=$(curl -s -o /tmp/out.json -w "%{http_code}" \
    -u "${USER}:${PASS}" -H "Content-Type: application/json" \
    -X POST "${GRAFANA_URL}/api/dashboards/db" -d "$payload")
  echo "$code $(basename "$f")"
done
```

Refresh Grafana **Dashboards** — you should see many dashboards listed.

---

## Problem 4 — Loki "Unable to connect" in Grafana

### Mistake beginners make

Using `http://localhost:3100` in the Loki datasource URL.

Grafana runs **inside** the cluster. `localhost` inside Grafana is **not** your laptop.

### Correct URL

```text
http://task-2-54-loki:3100
```

Steps:

1. **Connections** → **Data sources** → **Add** → **Loki**
2. URL: `http://task-2-54-loki:3100`
3. **Save & test** → green OK
4. **Explore** → Loki → query: `{namespace="ayoob-monitoring"}`

---

## Problem 5 — Grafana panel shows "No data"

| Panel type | Data source | Example |
|------------|-------------|---------|
| CPU, memory, pods | **Prometheus** | `sum(kube_pod_status_phase{...})` |
| Logs | **Loki** | `{namespace="$namespace"} \|= "error"` |

Common fixes:

1. Variable name must match: if variable is `namespace`, use `$namespace` (same spelling).
2. Stat panels: set query type to **Instant** (under query Options).
3. Test with fixed namespace first: `namespace="ayoob-monitoring"`.

---

## Full order we used (checklist)

Do steps in this order when setting up from scratch:

| # | Step | Command / action |
|---|------|------------------|
| 1 | Install prometheus stack | `helm install/upgrade ayoob-prometheus-stack ...` |
| 2 | Copy `kube-root-ca.crt` | kubectl copy from kube-system |
| 3 | Fix Grafana with Secret | `./fix-grafana-secrets.sh` |
| 4 | Fix node-exporter | values: `hostPort: null`, helm upgrade |
| 5 | Port-forward Grafana | `kubectl port-forward ... 3000:80` |
| 6 | Export dashboards | loop to `dashboards/*.json` |
| 7 | Import dashboards | UI or curl script |
| 8 | Install Loki | `helm install task-2-54-loki ...` |
| 9 | Add Loki datasource | URL `http://task-2-54-loki:3100` |
| 10 | Build Task 2.54 dashboard | Grafana UI |

---

## Simple picture (what we fixed)

```
NORMAL (healthy cluster):
  Helm creates ConfigMap → kubelet mounts it into pod → Grafana starts

OUR CLUSTER (broken mount):
  Helm creates ConfigMap → kubectl sees it ✓
                        → kubelet CANNOT mount ✗
                        → we use Secret instead ✓
                        → Grafana starts ✓
```

More diagrams: [ARCHITECTURE-configmap-to-pod.md](./ARCHITECTURE-configmap-to-pod.md)

---

## When to ask the instructor (not fix yourself)

Ask for help if:

- `fix-grafana-secrets.sh` runs but Grafana still not `1/1 Running`
- Loki pod not `1/1` after 10 minutes
- Many pods Pending on all nodes (cluster full)
- Errors mention `IOError`, disk, or etcd everywhere

Tell them: namespace `ayoob-monitoring`, paste `kubectl describe pod` for Grafana, and say ConfigMap exists but mount fails.

---

## Files to keep in your project

| File | What it is for |
|------|----------------|
| `BEGINNER-GUIDE-fix-configmap-issues.md` | **This guide** — start here |
| `ARCHITECTURE-configmap-to-pod.md` | Diagrams for learning |
| `TROUBLESHOOTING-configmap-and-grafana.md` | Detailed technical notes |
| `fix-grafana-secrets.sh` | One command to fix Grafana mount |
| `ayoob-monitoring-values.yaml` | Helm settings for our cluster |
| `dashboards/*.json` | Exported Grafana dashboards |

---

## Quick commands (copy-paste)

```bash
# Status
kubectl get pods -n ayoob-monitoring

# Fix Grafana
./fix-grafana-secrets.sh

# Open Grafana
kubectl port-forward -n ayoob-monitoring svc/ayoob-prometheus-stack-grafana 3000:80

# Grafana logs
kubectl logs -n ayoob-monitoring -l app.kubernetes.io/name=grafana -c grafana --tail=30
```

---

*Written for internship Tasks 2.52–2.54 on Civo k3s shared cluster.*
