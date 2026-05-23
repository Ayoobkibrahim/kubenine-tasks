#!/usr/bin/env bash
# Auto-load all Grafana dashboards from ConfigMaps into a Secret.
#
# Why this script exists:
#   - kubelet on this cluster cannot mount ConfigMap volumes (returns
#     "ConfigMap not found" even when kubectl shows it).
#   - The Grafana dashboard sidecar fails with 504 ResourceVersionTooLarge
#     because the cluster API has multi-apiserver consistency issues.
#   - Secret-volume mounts DO work, so we convert everything to Secrets.
#
# What it does:
#   1. Bundle main grafana config (grafana.ini + datasources.yaml) into a Secret.
#   2. Bundle the dashboardProviders provisioning file into a Secret.
#   3. Bundle ALL ConfigMaps labeled grafana_dashboard=1 into ONE Secret
#      (each CM becomes one .json file).
#   4. Patch the Grafana deployment to mount these Secrets at the right paths.
#   5. Restart the Grafana pod.
#
# Run after every `helm upgrade` AND whenever new dashboard ConfigMaps appear.

set -euo pipefail

NS=ayoob-monitoring
RELEASE=ayoob-prometheus-stack

# ---------- 1. Main grafana config Secret (grafana.ini + datasources + provider) ----------
GRAFANA_INI=$(kubectl get configmap "${RELEASE}-grafana" -n "$NS" -o jsonpath='{.data.grafana\.ini}')
DS=$(kubectl get configmap "${RELEASE}-grafana" -n "$NS" -o jsonpath='{.data.datasources\.yaml}')
PROV=$(kubectl get configmap "${RELEASE}-grafana" -n "$NS" -o jsonpath='{.data.dashboardproviders\.yaml}')

kubectl create secret generic ayoob-grafana-config-secret \
  --from-literal=grafana.ini="$GRAFANA_INI" \
  --from-literal=datasources.yaml="$DS" \
  --from-literal=dashboardproviders.yaml="$PROV" \
  -n "$NS" --dry-run=client -o yaml | kubectl apply -f -

# ---------- 3. Bundle ALL dashboard CMs into one Secret ----------
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

DASHBOARD_CMS=$(kubectl get cm -n "$NS" -l grafana_dashboard=1 -o jsonpath='{.items[*].metadata.name}')
COUNT=0
for cm in $DASHBOARD_CMS; do
  # Extract the JSON file inside each CM (key name varies, take the first)
  kubectl get cm "$cm" -n "$NS" -o json \
    | python3 -c "
import json, sys
d = json.load(sys.stdin)
items = list(d.get('data', {}).items())
if not items:
    sys.exit(0)
# Each CM has one .json file; use its key as the filename
key, content = items[0]
fname = key if key.endswith('.json') else f'{key}.json'
sys.stdout.write(content)
" > "$TMPDIR/${cm}.json"
  if [ -s "$TMPDIR/${cm}.json" ]; then
    COUNT=$((COUNT + 1))
  else
    rm -f "$TMPDIR/${cm}.json"
  fi
done
echo "Bundled $COUNT dashboards into ayoob-grafana-dashboards-secret"

# Create the dashboards Secret from the directory
FROM_FILE_ARGS=()
for f in "$TMPDIR"/*.json; do
  FROM_FILE_ARGS+=(--from-file="$(basename "$f")=$f")
done

# Note: cannot use `kubectl apply` here — bundled dashboards exceed the
# 256KB annotation limit that apply stores as `last-applied-configuration`.
# Use delete + create instead.
kubectl delete secret ayoob-grafana-dashboards-secret -n "$NS" --ignore-not-found
kubectl create secret generic ayoob-grafana-dashboards-secret \
  "${FROM_FILE_ARGS[@]}" \
  -n "$NS"

# ---------- 4. Patch Grafana deployment to mount Secrets ----------
kubectl get deployment "${RELEASE}-grafana" -n "$NS" -o json \
  | python3 -c "
import json, sys

d = json.load(sys.stdin)
pod = d['spec']['template']['spec']
vols = pod['volumes']
container = next(c for c in pod['containers'] if c['name'] == 'grafana')
mounts = container['volumeMounts']

# 4a. 'config' volume: ConfigMap -> Secret (all 3 keys: ini, datasources, providers)
for v in vols:
    if v['name'] == 'config':
        v.pop('configMap', None)
        v['secret'] = {
            'secretName': 'ayoob-grafana-config-secret',
            'items': [
                {'key': 'grafana.ini',             'path': 'grafana.ini'},
                {'key': 'datasources.yaml',        'path': 'datasources.yaml'},
                {'key': 'dashboardproviders.yaml', 'path': 'dashboardproviders.yaml'},
            ],
        }

# 4b. Add dashboards Secret volume + mount (if not already present)
DASH_VOL = 'auto-dashboards'
DASH_PATH = '/var/lib/grafana/dashboards/auto'
if not any(v['name'] == DASH_VOL for v in vols):
    vols.append({
        'name': DASH_VOL,
        'secret': {'secretName': 'ayoob-grafana-dashboards-secret'},
    })
if not any(m.get('name') == DASH_VOL for m in mounts):
    mounts.append({
        'name': DASH_VOL,
        'mountPath': DASH_PATH,
        'readOnly': True,
    })

print(json.dumps(d))
" \
  | kubectl apply -f -

# ---------- 5. Restart Grafana ----------
kubectl delete pod -n "$NS" -l app.kubernetes.io/name=grafana --force --grace-period=0

echo ""
echo "Done. Wait ~30s, then check:"
echo "  kubectl get pods -n $NS -l app.kubernetes.io/name=grafana"
echo "  kubectl port-forward -n $NS svc/${RELEASE}-grafana 3000:80"
