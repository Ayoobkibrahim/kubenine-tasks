# Task 2.54 — Custom Grafana Dashboard and Loki Log Querying

# Dashboard Focus

This dashboard focuses on namespace-level workload health monitoring.

The pre-built Grafana dashboards mainly showed cluster-wide metrics but did not provide a single operational view combining namespace-specific pod count, CPU usage, memory usage, restart count, and live error logs together.

This custom dashboard solves that gap by giving operators one reusable dashboard for monitoring workload health and troubleshooting issues inside any Kubernetes namespace using both Prometheus metrics and Loki logs.

---

# Loki Verification

Loki data source was added successfully in Grafana using:

http://task-2-54-loki.ayoob-monitoring.svc.cluster.local:3100

The following query was executed successfully in Grafana Explore view:

```logql
{namespace="ayoob-monitoring"}
```

Logs from the monitoring namespace were visible, confirming Loki and Promtail were working correctly.

---

# LogQL Queries

## 1. All Logs From Monitoring Namespace

### Query

```logql
{namespace="ayoob-monitoring"}
```

### Purpose

Shows all logs collected from the ayoob-monitoring namespace.

### Sample Output

```text
level=info caller=metrics.go
level=warn caller=operator.go
```

---

## 2. Logs From Grafana Pods

### Query

```logql
{namespace="ayoob-monitoring", pod=~".*grafana.*"}
```

### Purpose

Filters logs only from Grafana pods inside the monitoring namespace.

### Sample Output

```text
logger=dashboard-service level=info
logger=tsdb.loki level=info
```

---

## 3. Error Logs From Any Namespace

### Query

```logql
{namespace=~".+"} |= "error"
```

### Purpose

Shows log lines containing the word "error" from all namespaces.

### Sample Output

```text
level=error msg="failed to save dashboard"
level=error msg="error processing request"
```

---

## 4. Error Logs Excluding 404 Noise

### Query

```logql
{namespace=~".+"} |= "error" != "404"
```

### Purpose

Shows error logs while filtering out noisy 404-related messages.

### Sample Output

```text
level=error msg="context canceled"
level=error msg="request timeout"
```

---

## 5. Log Line Rate Per Namespace

### Query

```logql
sum(rate({namespace=~".+"}[5m])) by (namespace)
```

### Purpose

Converts logs into a metric showing log lines per second grouped by namespace.

### Sample Output

```text
namespace="ayoob-monitoring" 1.5
namespace="kube-system" 0.7
```

---

## 6. Parse JSON Logs and Filter Severity

### Query

```logql
{namespace="ayoob-monitoring"} | json | level=~"error|warn"
```

### Purpose

Parses JSON-formatted logs and filters logs based on severity level.

### Result

No JSON-formatted logs were available in this environment.

The `| json` parser is useful when applications emit structured JSON logs because fields like level, message, request_id, and status_code can be queried directly.

---

# Difference Between Stream Selector and Filter Expression

A stream selector chooses which log streams Loki should read based on labels such as namespace, pod, or container.

Example:

```logql
{namespace="ayoob-monitoring"}
```

A filter expression filters individual log lines after the streams are selected.

Example:

```logql
|= "error"
```

The stream selector limits the search scope, while the filter expression searches inside the selected logs.

---

# Why Loki Only Indexes Labels

Loki indexes only labels instead of indexing full log contents like Elasticsearch.

This design greatly reduces storage costs and improves ingestion performance because log content is stored compressed without building expensive full-text indexes.

The trade-off is that searching log contents can be slower compared to Elasticsearch because Loki must scan log chunks during queries.

---

# Dashboard Panels

## Panel 1 — Running Pods

### Type

Stat

### Query

```promql
count(
  kube_pod_info{
    namespace=~"$namespace"
  }
)
```

### Purpose

Shows the total number of pods running inside the selected namespace.

### Operational Question

How many pods currently exist inside this namespace?

---

## Panel 2 — CPU Usage

### Type

Time Series

### Query

```promql
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    namespace=~"$namespace",
    container!="",
    image!=""
  }[5m])
)
```

### Purpose

Shows CPU usage trends for pods inside the selected namespace.

### Operational Question

Which pods are consuming the most CPU resources?

---

## Panel 3 — Memory Usage

### Type

Time Series

### Query

```promql
sum by (pod) (
  container_memory_working_set_bytes{
    namespace=~"$namespace",
    container!="",
    image!=""
  }
)
```

### Purpose

Shows memory usage for pods inside the selected namespace.

### Operational Question

Which pods are consuming large amounts of memory?

---

## Panel 4 — Container Restarts

### Type

Time Series

### Query

```promql
sum by (pod) (
  increase(kube_pod_container_status_restarts_total{
    namespace=~"$namespace"
  }[1h])
)
```

### Purpose

Shows restart increases during the last one hour.

### Operational Question

Are any pods crashing repeatedly?

---

## Panel 5 — Error Logs

### Type

Logs

### Data Source

Loki

### Query

```logql
{namespace=~"$namespace"} |~ "(?i)error|failed|panic|fatal"
```

### Purpose

Shows important error logs from the selected namespace.

### Operational Question

What application or infrastructure errors are happening right now?

---

# Mandatory Questions

## What is Promtail and what is its role in the Loki stack? Where does it run in the cluster?

Promtail is the log collection agent used by Loki. It runs as a DaemonSet on Kubernetes nodes. Promtail reads container log files from the node filesystem, attaches Kubernetes labels like namespace and pod name, and pushes the logs to Loki.

---

## Why does Loki only index labels and not log content? What is the main trade-off of this design compared to Elasticsearch?

Loki indexes only labels to reduce storage costs and improve ingestion speed. This makes Loki lightweight and efficient. The trade-off is slower full-text searching because log contents are scanned during queries instead of being fully indexed.

---

## What is a LogQL stream selector? What happens if you write a query without one?

A stream selector defines which log streams Loki should search using labels.

Example:

```logql
{namespace="ayoob-monitoring"}
```

A LogQL query must always contain a stream selector. Without it, the query is invalid.

---

## What is the difference between |= "error" and | json | level="error" in LogQL?

`|= "error"` searches raw log text for the string "error".

`| json | level="error"` first parses structured JSON logs and then filters logs where the level field equals error.

The second method is more accurate for structured logging.

---

## What is a metric query in LogQL — how do you convert a log stream into a rate metric?

A metric query converts logs into numerical metrics using functions like rate().

Example:

```logql
sum(rate({namespace=~".+"}[5m])) by (namespace)
```

This calculates log lines per second for each namespace.

---

## What is a Grafana dashboard variable and how does it make a dashboard reusable?

A Grafana dashboard variable allows dynamic filtering of dashboard queries.

The `$namespace` variable lets the same dashboard work for multiple namespaces without changing panel queries manually.

---

## How did you decide what panels to put in your custom dashboard? What operational question does each one answer?

The dashboard was designed to monitor workload health inside namespaces.

- Running Pods → How many pods exist?
- CPU Usage → Which pods consume CPU?
- Memory Usage → Which pods consume memory?
- Container Restarts → Are pods crashing?
- Error Logs → What failures are occurring?

---

## What is the difference between a Stat panel and a Time Series panel in Grafana? When would you use each?

A Stat panel displays a single current value.

Example:
- Current pod count

A Time Series panel shows values changing over time.

Example:
- CPU usage trends

Stat panels are useful for current state information, while Time Series panels are useful for historical trends.

---

## What does the $namespace variable in your dashboard actually do to the PromQL query?

The `$namespace` variable dynamically replaces the namespace label value inside queries.

Example:

```promql
namespace=~"$namespace"
```

When the dropdown changes, Grafana automatically updates all queries using the selected namespace.

---

## Why is it useful to have Prometheus metric panels and Loki log panels on the same dashboard?

Combining metrics and logs allows operators to correlate system behavior and errors together.

Example:
A CPU spike can be immediately compared with application error logs on the same dashboard.

This improves troubleshooting speed.

---

## What is a Grafana transformation and when would you use one?

A Grafana transformation modifies query results before visualization.

Examples:
- Rename fields
- Merge tables
- Calculate values
- Filter data

Transformations are useful when raw query output needs reshaping before display.

---

## If a pod is crashing repeatedly, which panels on your custom dashboard would you look at first and why?

The first panels to check would be:

1. Container Restarts
2. CPU Usage
3. Memory Usage
4. Error Logs

Restart spikes indicate instability, while CPU, memory, and logs help identify the root cause.

---

# Conclusion

This task successfully implemented a complete namespace-level observability dashboard using Prometheus, Grafana, Loki, and Promtail.

The dashboard combines:
- Metrics
- Logs
- Dynamic namespace filtering
- Custom PromQL queries
- Custom LogQL queries

This setup provides a production-style observability workflow for Kubernetes troubleshooting and monitoring.