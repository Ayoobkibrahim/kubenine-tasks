# Task 2.52 — Part 2: Learn Metric Types from the Cluster

**Deliverable:** `task-2-52-metric-types.md`

**See also:** [Part 3 — PromQL queries & screenshots](./task-2-52-promql.md) · [Part 4 — target failure](./task-2-52-target-failure.md)

---

In the Prometheus **Graph** tab, each metric below was run as an instant query (metric name only, unless noted). Type comes from Prometheus exposition (`# TYPE …`) and behavior in the UI; a one-line meaning is given for each.

## `node_cpu_seconds_total`

| | |
|---|---|
| **PromQL (instant)** | `node_cpu_seconds_total` |
| **Type** | **Counter** |
| **What it measures** | Cumulative **CPU time in seconds** spent in each mode (`idle`, `user`, `system`, …) per logical CPU — the value only increases (resets on process restart). |

## `node_memory_MemAvailable_bytes`

| | |
|---|---|
| **PromQL (instant)** | `node_memory_MemAvailable_bytes` |
| **Type** | **Gauge** |
| **What it measures** | **Bytes of memory** the kernel considers available for applications **right now** — it can rise or fall as workload and caching change. |

## `kube_pod_info`

| | |
|---|---|
| **PromQL (instant)** | `kube_pod_info` |
| **Type** | **Gauge** (informational; value is typically **`1`**) |
| **What it measures** | One series per pod with **labels** describing that pod (`namespace`, `pod`, node, IP, …); the numeric value is a placeholder and filtering/joins use the labels. |

## `apiserver_request_duration_seconds_bucket`

| | |
|---|---|
| **PromQL (instant)** | `apiserver_request_duration_seconds_bucket` |
| **Type** | **Histogram** (`…_bucket` is the histogram bucket time series) |
| **What it measures** | **Cumulative count** of API server request durations falling in buckets labeled by `le` (upper bound), used with `_sum` / `_count` for latency rates and quantiles. |

## `go_gc_duration_seconds`

| | |
|---|---|
| **PromQL (instant)** | `go_gc_duration_seconds` |
| **Type** | **Summary** |
| **What it measures** | **Go runtime GC pause duration** with client-computed quantiles (`quantile` label); unlike a histogram, quantiles are calculated in the process that exports the metric. |
