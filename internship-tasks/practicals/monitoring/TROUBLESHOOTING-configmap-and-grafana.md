# Troubleshooting Guide: ConfigMap Mount Issues, Grafana, and Monitoring Stack

**Cluster:** Civo k3s internship (`kubenine`)  
**Namespace:** `ayoob-monitoring`  
**Helm release:** `ayoob-prometheus-stack`  
**Context:** Shared cluster with multiple interns; disk/API pressure common.

This document explains the problems encountered during Tasks 2.52–2.54, the diagnosis steps used, workarounds that worked, and what requires a platform admin to fix permanently.

---

## Table of contents

1. [Symptoms summary](#1-symptoms-summary)
2. [How ConfigMaps reach a pod](#2-how-configmaps-reach-a-pod)
3. [Layer 1: Missing kube-root-ca.crt](#3-layer-1-missing-kube-root-cacrt)
4. [Layer 2: ConfigMap not found but kubectl sees it](#4-layer-2-configmap-not-found-but-kubectl-sees-it)
5. [Layer 3: Secret volume workaround (Grafana)](#5-layer-3-secret-volume-workaround-grafana)
6. [Layer 4: Node-exporter Pending (host port)](#6-layer-4-node-exporter-pending-host-port)
7. [Layer 5: Empty Grafana dashboards](#7-layer-5-empty-grafana-dashboards)
8. [Layer 6: Loki datasource connection](#8-layer-6-loki-datasource-connection)
9. [Layer 7: Grafana panel No data](#9-layer-7-grafana-panel-no-data)
10. [Master troubleshooting flowchart](#10-master-troubleshooting-flowchart)
11. [Command cheat sheet](#11-command-cheat-sheet)
12. [Files in this repo](#12-files-in-this-repo)
13. [What to escalate to admin](#13-what-to-escalate-to-admin)
14. [Mental model (one paragraph)](#14-mental-model-one-paragraph)

---

## 1. Symptoms summary

Three problems looked like one Grafana bug. They were **separate layers**:

| ID | Symptom | Typical message / sign |
|----|---------|----------------------|
| A | Grafana stuck `ContainerCreating` | `FailedMount` in pod events |
| B | ConfigMap "not found" | `configmap "ayoob-prometheus-stack-grafana" not found` |
| C | API vs kubelet mismatch | `kubectl get cm` shows CM exists |
| D | node-exporter `Pending` | `didn't have free ports for the requested pod ports` |
| E | Dashboard sidecar crash | `504 ResourceVersionTooLarge` |
| F | Empty exported JSON files | `JSONDecodeError: Expecting value` on import |

**Key lesson:** `kubectl get configmap` succeeding does **not** prove the kubelet can mount that ConfigMap into a new pod.

---

## 2. How ConfigMaps reach a pod

### Normal flow

1. **Helm** (or `kubectl apply`) creates ConfigMap objects in the Kubernetes API (stored in etcd).
2. A **Pod** spec references the ConfigMap: `volumes[].configMap.name: <name>`.
3. **Kubelet** on the scheduled node fetches the object from the API and mounts files into the container filesystem.
4. The container starts and reads those files (e.g. `grafana.ini`).

### Where failures happen

| Step | Failure example |
|------|-----------------|
| Object not created | Helm failed partially; wrong release name |
| API/etcd unhealthy | Objects exist but watches are stale |
| Kubelet cannot read CM | "ConfigMap not found" on mount |
| Wrong volume type / path | Mount succeeds but wrong file path |
| Controller missing | `kube-root-ca.crt` never published to namespace |

---

## 3. Layer 1: Missing kube-root-ca.crt

### What it is

The **`root-ca-cert-publisher`** controller (part of kube-controller-manager / k3s) should create ConfigMap **`kube-root-ca.crt`** in every namespace so pods can trust the cluster CA via projected service account volumes.

### How we detected it

```bash
kubectl get configmap kube-root-ca.crt -n ayoob-monitoring
# Error: NotFound

kubectl get configmap kube-root-ca.crt -n kube-system
# Exists
```

### Impact

- Projected volume `kube-api-access-*` references `kube-root-ca.crt`.
- Can contribute to volume mount failures for pods in affected namespaces.

### Manual fix (per namespace — you can do this)

```bash
kubectl get configmap kube-root-ca.crt -n kube-system -o yaml \
  | sed 's/namespace: kube-system/namespace: ayoob-monitoring/' \
  | grep -v 'resourceVersion:\|uid:\|creationTimestamp:' \
  | kubectl apply -f -
```

Verify:

```bash
kubectl get configmap kube-root-ca.crt -n ayoob-monitoring
```

Restart affected pods so volumes remount:

```bash
kubectl delete pod -n ayoob-monitoring -l app.kubernetes.io/name=grafana
```

### Permanent fix (cluster admin only)

- Repair/restart kube-controller-manager or k3s server.
- Confirm `root-ca-cert-publisher` runs without errors.
- New namespaces then receive `kube-root-ca.crt` automatically.

**Scope:** Manual copy fixes **one namespace**, not the entire cluster for all users.

---

## 4. Layer 2: ConfigMap not found but kubectl sees it

### Symptom

```text
Warning  FailedMount  MountVolume.SetUp failed for volume "config":
  configmap "ayoob-prometheus-stack-grafana" not found
```

Meanwhile:

```bash
kubectl get configmap ayoob-prometheus-stack-grafana -n ayoob-monitoring
# NAME exists, DATA 1
```

### Meaning

| Client | Sees ConfigMap? |
|--------|-----------------|
| kubectl (API) | Yes |
| Kubelet on worker node | No (or stale / cannot sync) |

This is **not** "Helm forgot the ConfigMap." It is a **kubelet ↔ API** or **cluster/etcd** issue on an overloaded shared cluster.

### Diagnosis steps (in order)

**Step 1 — Confirm object exists**

```bash
kubectl get configmap -n ayoob-monitoring | grep grafana
kubectl get configmap ayoob-prometheus-stack-grafana -n ayoob-monitoring -o yaml
```

**Step 2 — Read pod events**

```bash
kubectl describe pod -n ayoob-monitoring -l app.kubernetes.io/name=grafana
```

**Step 3 — Test new pod: ConfigMap vs Secret mount**

ConfigMap test (failed on this cluster):

```bash
kubectl run cm-test --image=busybox:1.36 --restart=Never -n ayoob-monitoring \
  --overrides='{"spec":{"volumes":[{"name":"g","configMap":{"name":"ayoob-prometheus-stack-grafana"}}],"containers":[{"name":"c","image":"busybox:1.36","command":["sleep","120"],"volumeMounts":[{"name":"g","mountPath":"/cfg"}]}]}}'
kubectl describe pod cm-test -n ayoob-monitoring
```

Secret test (succeeded):

```bash
kubectl create secret generic test-mount-secret --from-literal=k=test -n ayoob-monitoring
# ... mount secret in test pod → Running
```

**Conclusion:** ConfigMap volume plugin broken for new mounts; Secret mounts still work.

**Step 4 — Already-running pods**

Prometheus had ConfigMaps mounted when it started earlier. New pods could not mount ConfigMaps afterward. Old mounts kept working; new mounts failed.

### Fixes attempted

| Attempt | Command / action | Result on this cluster |
|---------|------------------|------------------------|
| Helm reconcile | `helm upgrade ayoob-prometheus-stack ... -f ayoob-monitoring-values.yaml` | CMs exist in API; mount still fails |
| Recreate CMs | Delete CM + `helm template` + `kubectl apply` | Still fails on kubelet |
| Delete Grafana pod | Force new mount attempt | Still fails until Secret workaround |
| Copy kube-root-ca.crt | See Layer 1 | Required but not sufficient alone |

---

## 5. Layer 3: Secret volume workaround (Grafana)

### Why Secrets worked

Kubelet uses different code paths for `configMap` vs `secret` volumes. On this cluster, **Secrets mounted; ConfigMaps did not** for new pods.

### Procedure

**1. Read ConfigMap data via API (kubectl still works)**

```bash
GRAFANA_INI=$(kubectl get configmap ayoob-prometheus-stack-grafana -n ayoob-monitoring \
  -o jsonpath='{.data.grafana\.ini}')

DS=$(kubectl get configmap ayoob-prometheus-stack-grafana -n ayoob-monitoring \
  -o jsonpath='{.data.datasources\.yaml}')
```

Note: Escape dots in jsonpath keys (`grafana\.ini`).

**2. Create Secret with same content**

```bash
kubectl create secret generic ayoob-grafana-config-secret \
  --from-literal=grafana.ini="$GRAFANA_INI" \
  --from-literal=datasources.yaml="$DS" \
  -n ayoob-monitoring
```

**3. Patch Deployment — replace ConfigMap volume with Secret**

```bash
kubectl patch deployment ayoob-prometheus-stack-grafana -n ayoob-monitoring --type=json -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/volumes/0",
    "value": {
      "name": "config",
      "secret": {
        "secretName": "ayoob-grafana-config-secret",
        "items": [
          {"key": "grafana.ini", "path": "grafana.ini"},
          {"key": "datasources.yaml", "path": "datasources.yaml"}
        ]
      }
    }
  }
]'
```

**4. Restart Grafana pod**

```bash
kubectl delete pod -n ayoob-monitoring -l app.kubernetes.io/name=grafana
```

### Automation script

After every `helm upgrade`, run:

```bash
./fix-grafana-secrets.sh
```

Location: `internship-tasks/practicals/monitoring/fix-grafana-secrets.sh`

### Important

This is a **workaround**, not a root-cause fix. Production fix = restore kubelet/API/etcd health.

---

## 6. Layer 4: Node-exporter Pending (host port)

### Symptom

```text
0/2 nodes are available: 1 node(s) didn't have free ports for the requested pod ports
```

### Cause

Default `prometheus-node-exporter` chart uses **`hostPort: 9100`**. On a shared cluster, many students' DaemonSets already bind port 9100 on the same node.

### Fix in `ayoob-monitoring-values.yaml`

```yaml
nodeExporter:
  enabled: true

prometheus-node-exporter:
  hostNetwork: false
  hostPID: false
  hostPort: null
  service:
    port: 9100
    targetPort: 9100
```

Prometheus scrapes via Service/Pod IP, not host port.

### Optional: reduce load on busy node

```yaml
grafana:
  nodeSelector:
    kubernetes.io/hostname: k3s-kubenine-intern-3048-ed140f-node-pool-0576-9nfz5

prometheus:
  prometheusSpec:
    nodeSelector:
      kubernetes.io/hostname: k3s-kubenine-intern-3048-ed140f-node-pool-0576-9nfz5
```

Node `kamwk` had ~95% memory limits allocated; Prometheus was OOMKilled there earlier.

---

## 7. Layer 5: Empty Grafana dashboards

### Why dashboards were empty

| Component | Status on this cluster |
|-----------|------------------------|
| Helm created ~27 dashboard ConfigMaps (`grafana_dashboard=1`) | Yes |
| Dashboard sidecar enabled | No (disabled on purpose) |
| Sidecar when enabled | Crashes: API `504 ResourceVersionTooLarge` |
| Sidecar mounts dashboard provider CM | Failed (Layer 2) |

Grafana ran with Prometheus datasource; pre-built dashboards were never loaded into the UI.

### Why sidecar was disabled

```yaml
grafana:
  sidecar:
    dashboards:
      enabled: false
    datasources:
      enabled: false
```

Enabling sidecar caused CrashLoopBackOff due to cluster API/etcd overload when listing ConfigMaps.

### Workaround: Manual export and import

**Export bug — wrong jsonpath (dots in key names)**

```bash
# WRONG — produces empty files
kubectl get cm ... -o jsonpath='{.data.grafana-overview.json}'

# RIGHT
kubectl get cm <name> -n ayoob-monitoring -o json | python3 -c "
import json, sys
d = json.load(sys.stdin)
key = list(d['data'].keys())[0]
sys.stdout.write(d['data'][key])
" > dashboards/<name>.json
```

**Bulk export loop**

```bash
mkdir -p dashboards
for cm in $(kubectl get cm -n ayoob-monitoring -l grafana_dashboard=1 -o jsonpath='{.items[*].metadata.name}'); do
  kubectl get cm "$cm" -n ayoob-monitoring -o json | python3 -c "
import json, sys
d = json.load(sys.stdin)
key = list(d['data'].keys())[0]
sys.stdout.write(d['data'][key])
" > "dashboards/${cm}.json"
done
```

**Bulk import via Grafana API** (with port-forward on port 3000)

```bash
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
  curl -s -o /tmp/out.json -w "%{http_code}" -u "${USER}:${PASS}" \
    -H "Content-Type: application/json" \
    -X POST "${GRAFANA_URL}/api/dashboards/db" -d "$payload"
  echo " $(basename "$f")"
done
```

---

## 8. Layer 6: Loki datasource connection

### Symptom

Grafana UI: **"Unable to connect with Loki"**

### Common mistake

| URL | Why it fails |
|-----|----------------|
| `http://localhost:3100` | localhost inside Grafana pod ≠ Loki |
| `http://127.0.0.1:3100` | Same |
| `http://prometheus-stack-loki.monitoring.svc...` | Wrong service/namespace (task example) |

### Correct URL (this deployment)

```text
http://task-2-54-loki:3100
```

or:

```text
http://task-2-54-loki.ayoob-monitoring.svc.cluster.local:3100
```

### Verify from Grafana pod

```bash
kubectl exec -n ayoob-monitoring deploy/ayoob-prometheus-stack-grafana -c grafana -- \
  wget -qO- http://task-2-54-loki:3100/ready
# Expected: ready
```

### Port-forward note

- `kubectl port-forward ... grafana 3000:80` → for **your browser** only.
- Loki URL in Grafana settings must be **in-cluster DNS**, because the **Grafana pod** calls Loki, not your laptop.

---

## 9. Layer 7: Grafana panel No data

### Not a ConfigMap issue

Prometheus had metrics. Panel showed "No data" due to Grafana configuration.

### Causes and fixes

| Cause | Fix |
|-------|-----|
| Variable name mismatch (`$Namespace` vs `$namespace`) | Variable **Name** must match query exactly (case-sensitive) |
| Stat panel using Range only | Set Prometheus query **Type: Instant** |
| Hardcode test | `namespace="ayoob-monitoring"` — if works, fix variable |
| LogQL in Prometheus datasource | Switch to **Loki** + **Logs** visualization for log panels |

### Example: Running pods (Stat, Instant)

```promql
sum(kube_pod_status_phase{namespace="$namespace", phase="Running"} == 1)
```

### Example: Error logs (Loki only)

```logql
{namespace="$namespace"} |= "error"
```

**Never** use `|=` or `|~` with Prometheus — that is LogQL.

---

## 10. Master troubleshooting flowchart

```text
Pod stuck ContainerCreating + FailedMount ConfigMap?
│
├─ kubectl get cm <name> -n <ns>
│   ├─ NOT FOUND
│   │   └─ helm upgrade / helm template | kubectl apply (recreate CM)
│   └─ FOUND
│       └─ Kubelet/API issue (Layer 2)
│           ├─ Secret mount works, CM mount fails?
│           │   └─ YES → Secret workaround + patch Deployment
│           ├─ kube-root-ca.crt missing?
│           │   └─ Copy from kube-system (Layer 1)
│           └─ Escalate to admin (etcd/kubelet/controller)
│
DaemonSet Pending + "free ports"?
└─ hostPort: null, hostNetwork: false (Layer 4)

Grafana dashboards empty?
├─ Sidecar enabled and healthy? → usually NO on this cluster
└─ Export CM with Python → import via UI or API (Layer 5)

Loki "Unable to connect"?
└─ In-cluster service URL, not localhost (Layer 6)

Panel "No data" but Explore works?
└─ Variable name, Instant query, correct datasource (Layer 7)
```

---

## 11. Command cheat sheet

```bash
# --- Namespace / pods ---
kubectl get pods -n ayoob-monitoring
kubectl describe pod <pod> -n ayoob-monitoring

# --- ConfigMaps ---
kubectl get cm -n ayoob-monitoring
kubectl get cm -n ayoob-monitoring -l grafana_dashboard=1

# --- root-ca.crt ---
kubectl get cm kube-root-ca.crt -n ayoob-monitoring
kubectl get cm kube-root-ca.crt -n kube-system -o yaml | \
  sed 's/namespace: kube-system/namespace: ayoob-monitoring/' | kubectl apply -f -

# --- Helm ---
helm list -n ayoob-monitoring
helm upgrade ayoob-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 85.1.3 -n ayoob-monitoring -f ayoob-monitoring-values.yaml

# --- Grafana secret workaround ---
./fix-grafana-secrets.sh

# --- Prometheus test (port-forward 9090) ---
kubectl port-forward -n ayoob-monitoring svc/ayoob-prometheus-stack-kub-prometheus 9090:9090
curl -s --get 'http://127.0.0.1:9090/api/v1/query' \
  --data-urlencode 'query=count(kube_pod_info{namespace="ayoob-monitoring"})'

# --- Loki test ---
kubectl port-forward -n ayoob-monitoring svc/task-2-54-loki 3100:3100
curl -s http://127.0.0.1:3100/ready

# --- Grafana UI ---
kubectl port-forward -n ayoob-monitoring svc/ayoob-prometheus-stack-grafana 3000:80
```

---

## 12. Files in this repo

| File | Purpose |
|------|---------|
| `ayoob-monitoring-values.yaml` | Prometheus stack values: no hostPort, sidecars off, nodeSelector |
| `fix-grafana-secrets.sh` | Re-apply Secret volume patch after `helm upgrade` |
| `dashboards/*.json` | Exported pre-built Grafana dashboards |
| `Task-2-54/task-2-54-loki-values.yaml` | Loki + Promtail Helm values |
| `Task-2-54/task-2-54-logql.md` | Task 2.54 LogQL documentation |
| `Task-2-54/task-2-54-dashboard.json` | Exported custom dashboard |

---

## 13. What to escalate to admin

Provide:

1. Namespace: `ayoob-monitoring`
2. `kubectl describe pod` — full `FailedMount` events
3. Proof: `kubectl get cm <name>` exists but kubelet says not found
4. Proof: Secret test pod mounts; ConfigMap test pod fails
5. Sidecar/API errors: `ResourceVersionTooLarge`, HTTP 504
6. Node events: `IOError`, disk warnings (if present)

Request:

- Restore **root-ca-cert-publisher**
- Fix **etcd/API watch** lag (ResourceVersion gap)
- Investigate **kubelet ConfigMap volume** failures on worker nodes

---

## 14. Mental model (one paragraph)

**Helm** writes objects to the **Kubernetes API**. **Kubelet** on each worker node must fetch and **mount** them into pods. If `kubectl get configmap` succeeds but the kubelet reports "ConfigMap not found," the problem is on the **node/API/etcd path**, not in your Helm values. On a degraded shared cluster you can sometimes **bypass** ConfigMap mounts using **Secrets**, **disable** components that need ConfigMap mounts (Grafana dashboard sidecar), and **manually import** dashboard JSON. The **permanent** fix is always platform-level: restore controllers, etcd consistency, and kubelet volume plugins—not repeated `helm upgrade` alone.

---

## Revision history

| Date | Notes |
|------|-------|
| 2026-05-20 | Initial document from internship troubleshooting session |

---

*Author: internship monitoring stack (ayoob-monitoring). For Tasks 2.52, 2.53, 2.54.*
