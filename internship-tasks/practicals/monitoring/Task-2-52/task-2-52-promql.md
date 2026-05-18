# Task 2.52 — Part 3: Write and Document PromQL Queries

**Deliverable:** `task-2-52-promql.md` (required PromQL documentation for Task 2.52)

**Related:** [Part 2 — metric types](./task-2-52-metric-types.md) · [Part 4 — target failure](./task-2-52-target-failure.md)

Screenshots for this part live in **this same folder** as the image paths below.

---

### Query 1 — CPU usage rate per node (all cores, excluding idle)

**Category:** Counters and `rate()`

#### Query

```promql
rate(node_cpu_seconds_total{mode!="idle"}[5m])
```

#### What it computes

Per-second increase of CPU time spent in every non-idle CPU mode (`user`, `system`, `iowait`, …) over the last 5 minutes, per label set (cores, modes, instances).

#### Result observed

- Many series returned (one per `{cpu, mode, …}` combination on the node exporter).
- Example behaviors: dominant `mode="user"` activity; smaller contributions from `system`, `iowait`, etc.

#### Screenshots — Table

![Prometheus Table: rate(node_cpu_seconds_total{mode!="idle"}[5m])](./Screenshot%20from%202026-05-18%2016-11-16.png)

#### Screenshots — Graph

![Prometheus Graph: rate(node_cpu_seconds_total{mode!="idle"}[5m])](./Screenshot%20from%202026-05-18%2016-14-06.png)

---

### Query 2 — Total CPU usage percentage per node

**Category:** Counters and `rate()` (combined into a utilization %)

#### Query

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

#### What it computes

Non-idle CPU share as a percentage per `instance`: 100 minus the average idle rate (over 5m) × 100.

#### Result observed

- Single series per node: e.g. `instance="192.168.1.28:9100"` ≈ **13.24%** (value varies slightly with time).

#### Screenshots — Table

![Prometheus Table: CPU % from idle](./Screenshot%20from%202026-05-18%2016-12-25.png)

#### Screenshots — Graph

![Prometheus Graph: CPU % from idle](./Screenshot%20from%202026-05-18%2016-14-47.png)

---

### Query 3 — Memory used per node (bytes)

**Category:** Gauges

#### Query

```promql
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes
```

#### What it computes

Estimated **used RAM in bytes** on each node (`total − available`, from `node_exporter`).

#### Result observed

- Example: **`4705865728`** bytes (≈ 4.4 GiB used) on `instance="192.168.1.28:9100"`.

#### Screenshots — Table

![Prometheus Table: memory used bytes](./Screenshot%20from%202026-05-18%2016-15-30.png)

#### Screenshots — Graph

![Prometheus Graph: memory used bytes](./Screenshot%20from%202026-05-18%2016-15-44.png)

---

### Query 4 — Memory usage percentage per node

**Category:** Gauges

#### Query

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

#### What it computes

**Percent of RAM in use** on each node (`100 × (1 − available/total)`).

#### Result observed

- Example: **`29.37373901941436`** (~29.37%) on the sampled node.

#### Screenshots — Table

![Prometheus Table: memory %](./Screenshot%20from%202026-05-18%2016-16-08.png)

#### Screenshots — Graph

![Prometheus Graph: memory %](./Screenshot%20from%202026-05-18%2016-16-20.png)

---

### Query 5 — Total number of running pods per namespace

**Category:** Aggregation

#### Query

```promql
count by (namespace) (kube_pod_info)
```

#### What it computes

How many **`kube_pod_info` time series exist per namespace** — in practice this matches **pod counts per namespace** (each pod contributes labeled series depending on exposition).

#### Result observed

- Example namespaces from the UI table: `devanarayanan-r` **21**, `akash-c-a` **12**, `monitoring` **7**, `kube-system` **6**, plus `cert-manager`, `ingress-nginx`, `default`, `monitoring-hariharan`, etc.

#### Screenshots — Table

![Prometheus Table: count by namespace](./Screenshot%20from%202026-05-18%2016-16-49.png)

#### Screenshots — Graph

![Prometheus Graph: count by namespace](./Screenshot%20from%202026-05-18%2016-17-18.png)

---

### Aggregation experiment — remove `by (namespace)`

#### Query

```promql
count(kube_pod_info)
```

#### What changed and why

- **With `by (namespace)`:** Prometheus evaluates `count()` **within each distinct `namespace` value**, so you get **one series per namespace**.
- **Without `by (namespace)`:** `count(...)` aggregates over **the whole instant vector**, producing **one number** — the total number of input series matched by `kube_pod_info` cluster-wide.

#### Result observed

- **`56`** pods (single scalar series `{}`).

#### Screenshots — Table

![Prometheus Table: count(kube_pod_info)](./Screenshot%20from%202026-05-18%2016-17-52.png)

#### Screenshots — Graph

![Prometheus Graph: count(kube_pod_info)](./Screenshot%20from%202026-05-18%2016-18-02.png)

---

### Query 6 — API server request rate by HTTP verb

**Category:** Aggregation + `rate()` on counters

#### Query

```promql
sum(rate(apiserver_request_total[5m])) by (verb)
```

#### What it computes

**Requests/sec** (5m-smoothed) to the apiserver counter `apiserver_request_total`, summed so each output series is grouped by **`verb`** (GET, PUT, LIST, WATCH, …).

#### Result observed

- Examples from the UI: `GET` ≈ **1.60**/s, `PUT` ≈ **0.97**/s, `WATCH` ≈ **0.96**/s, `LIST` ≈ **0.13**/s, `POST` ≈ **0.14**/s (zeros for rare verbs depending on scrape window).

#### Screenshots — Table

![Prometheus Table: sum rate apiserver_request_total by verb](./Screenshot%20from%202026-05-18%2016-18-19.png)

#### Screenshots — Graph

![Prometheus Graph: sum rate apiserver_request_total by verb](./Screenshot%20from%202026-05-18%2016-18-31.png)

---

### Query 7 — P99 latency of API server requests (seconds)

**Category:** Histogram quantile

#### Query

```promql
histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket[5m])) by (le, verb))
```

#### What it computes

**Estimated 99th percentile latency in seconds** of apiserver handling time, evaluated **per `verb`** from histogram buckets (`_bucket`), using 5‑minute smoothed observation rates.

#### Result observed

- Examples: **`WATCH`** P99 **`60`**s (streaming/watches often dominate tail latency), **`LIST`** ≈ **4.68**s, **`GET`/`PUT`/`POST`** in the tens of milliseconds; **`NaN`** for verbs with insufficient histogram samples in the window.

#### Screenshots — Table

![Prometheus Table: histogram_quantile P99 apiserver latency](./Screenshot%20from%202026-05-18%2016-18-53.png)

#### Screenshots — Graph

![Prometheus Graph: histogram_quantile P99 apiserver latency](./Screenshot%20from%202026-05-18%2016-19-05.png)

---

### Query 8 — API server error rate (4xx and 5xx only)

**Category:** Label filtering + `rate()`

#### Query

```promql
sum(rate(apiserver_request_total{code=~"4..|5.."}[5m])) by (code)
```

#### What it computes

**Per-second rate** of apiserver requests whose HTTP **`code` matches 4xx or 5xx** (regex `4..|5..`), split by status code.

#### Result observed

- Series present for codes such as **400, 403, 404, 409, 422, 429, 500, 504** — all at **0**/s in the captured window (no errors in that interval).

#### Screenshots — Table

![Prometheus Table: error rate by code](./Screenshot%20from%202026-05-18%2016-19-23.png)

#### Screenshots — Graph

![Prometheus Graph: error rate by code](./Screenshot%20from%202026-05-18%2016-19-33.png)

---

## Summary

All **8 required PromQL expressions** from Part 3 were run in the Prometheus UI; this file records each query, what it measures, observed values, and **which screenshot** documents the Table vs Graph view. The **aggregation experiment** (`count` with vs without `by (namespace)`) is included with its own pair of screenshots.
