#!/usr/bin/env bash
# Re-apply after helm upgrade when kubelets cannot mount ConfigMaps in this namespace.
set -euo pipefail
NS=ayoob-monitoring
GRAFANA_INI=$(kubectl get configmap ayoob-prometheus-stack-grafana -n "$NS" -o jsonpath='{.data.grafana\.ini}')
DS=$(kubectl get configmap ayoob-prometheus-stack-grafana -n "$NS" -o jsonpath='{.data.datasources\.yaml}')
kubectl create secret generic ayoob-grafana-config-secret \
  --from-literal=grafana.ini="$GRAFANA_INI" \
  --from-literal=datasources.yaml="$DS" \
  -n "$NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl patch deployment ayoob-prometheus-stack-grafana -n "$NS" --type=json -p='[
  {"op": "replace", "path": "/spec/template/spec/volumes/0", "value": {
    "name": "config",
    "secret": {
      "secretName": "ayoob-grafana-config-secret",
      "items": [
        {"key": "grafana.ini", "path": "grafana.ini"},
        {"key": "datasources.yaml", "path": "datasources.yaml"}
      ]
    }
  }}
]'
kubectl delete pod -n "$NS" -l app.kubernetes.io/name=grafana --force --grace-period=0
