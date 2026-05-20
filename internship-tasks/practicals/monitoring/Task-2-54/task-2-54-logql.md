# Task 2.54 — Custom Grafana Dashboard and Loki Log Querying

---

# Dashboard Focus

This custom dashboard focuses on namespace-level workload monitoring for the `ayoob-monitoring` namespace.

The dashboard combines:
- pod statistics
- CPU usage
- memory usage
- restart monitoring
- centralized logs

into a single operational dashboard.

The goal is to quickly identify:
- unhealthy workloads
- application instability
- resource pressure
- troubleshooting information

from one place.

---

# Dashboard Name

```text
task-2-54-dashboard
```

---

# Dashboard Variable

## Variable Name

```text
namespace
```

## Query

```promql
label_values(kube_pod_info, namespace)
```

## Purpose

The namespace variable dynamically updates all dashboard panels based on the selected Kubernetes namespace.

This makes the dashboard reusable across multiple namespaces without modifying queries manually.

---

# Panel 1 — Running Pods

## Panel Type

```text
Stat
```

## Query

```promql
count(
  kube_pod_info{
    namespace="ayoob-monitoring"
  }
)
```

## Purpose

This panel displays the total number of running pods inside the selected namespace.

It helps quickly verify:
- workload availability
- namespace health
- pod deployment status

## Operational Question

```text
How many pods are currently running inside my namespace?
```

---

# Panel 2 — CPU Usage

## Panel Type

```text
Time Series
```

## Query

```promql
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    namespace=~"ayoob-monitoring",
    container!="",
    image!=""
  }[5m])
)
```

## Purpose

This panel shows real-time CPU usage for pods inside the selected namespace.

It helps identify:
- high CPU usage
- overloaded workloads
- abnormal CPU spikes

## Operational Question

```text
Which pods are consuming high CPU resources?
```

---

# Panel 3 — Memory Working Set by Pod

## Panel Type

```text
Time Series
```

## Query

```promql
sum by (pod) (
  container_memory_working_set_bytes{
    namespace="ayoob-monitoring",
    container!="",
    image!=""
  }
)
```

## Purpose

This panel displays active memory usage for all pods inside the namespace.

It helps detect:
- memory pressure
- memory leaks
- abnormal memory usage

## Operational Question

```text
Which pods are consuming high memory resources?
```

---

# Panel 4 — Container Restarts

## Panel Type

```text
Time Series
```

## Query

```promql
sum by (pod) (
  increase(kube_pod_container_status_restarts_total{
    namespace="ayoob-monitoring"
  }[1h])
)
```

## Purpose

This panel monitors container restart activity during the last one hour.

Frequent restarts usually indicate:
- application crashes
- unstable workloads
- configuration problems
- resource issues

## Operational Question

```text
Are any workloads crashing repeatedly?
```

---

# Panel 5 — Error Logs

## Panel Type

```text
Logs
```

## Data Source

```text
Loki
```

## Query

```logql
{namespace="ayoob-monitoring"} |= "error"
```

## Purpose

This panel retrieves important error-related logs from Loki.

It helps quickly identify:
- application failures
- runtime errors
- troubleshooting information

inside the selected namespace.

## Operational Question

```text
What application or infrastructure errors are happening right now?
```

---

# Dashboard Layout

The dashboard layout is organized based on operational priority.

| Section | Panels |
|---|---|
| Top | Running Pods |
| Middle | CPU Usage |
| Middle | Memory Working Set |
| Lower | Container Restarts |
| Bottom | Error Logs |

This layout improves:
- operational visibility
- troubleshooting efficiency
- namespace monitoring

---

# Technologies Used

| Component | Purpose |
|---|---|
| Grafana | Dashboard visualization |
| Prometheus | Metrics collection |
| Loki | Log aggregation |
| Promtail | Log collection |
| PromQL | Metrics querying |
| LogQL | Log querying |

---

# Dashboard JSON Export

The dashboard was exported successfully from:

```text
Dashboard Settings → JSON Model
```

and saved as:

```text
task-2-54-dashboard.json
```

---

# Conclusion

This task successfully implemented a namespace-focused observability dashboard using:
- Prometheus metrics
- Loki logs
- PromQL queries
- LogQL queries

The dashboard provides centralized visibility into:
- workload health
- resource usage
- restart activity
- application errors

inside the `ayoob-monitoring` namespace.