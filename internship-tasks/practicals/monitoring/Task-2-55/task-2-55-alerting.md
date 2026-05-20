# Task 2.55 — Grafana Alerting, Notification Policies, Silences, and Inhibition Rules

---

# Objective

The objective of this task is to implement Grafana-managed alerting using Prometheus metrics in a Kubernetes monitoring environment.

This task includes:

- Creating Grafana alert rules
- Configuring alert evaluation behavior
- Integrating Slack notifications
- Configuring notification policies
- Implementing alert silences
- Understanding inhibition rule design
- Reducing alert noise using Alertmanager concepts

---

# Environment

| Component | Purpose |
|---|---|
| Grafana | Alert management and visualization |
| Prometheus | Metrics collection |
| kube-state-metrics | Kubernetes object metrics |
| Node Exporter | Linux host metrics |
| Slack | Alert notification delivery |
| Kubernetes | Container orchestration platform |

---

# Alert Rule 1 — CPU Usage Alert

## Alert Name

task-2-55-cpu-alert

---

## Description

This alert monitors node CPU utilization using Prometheus Node Exporter metrics.

The alert triggers when node CPU usage exceeds 80%.

---

## PromQL Query

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

## Threshold

```text
IS ABOVE 80
```

---

## Labels

| Label | Value |
|---|---|
| severity | warning |
| team | platform |

---

## Evaluation Settings

| Setting | Value |
|---|---|
| Evaluation Interval | 1 minute |
| Pending Period | 2 minutes |
| Keep Firing For | 0 seconds |

---

# Alert Rule 2 — Pod Restart Alert

## Alert Name

task-2-55-pod-restart-alert

---

## Description

This alert monitors repeated pod restart activity using kube-state-metrics.

The alert helps identify crash-looping or unstable workloads inside Kubernetes clusters.

---

## PromQL Query

```promql
increase(kube_pod_container_status_restarts_total[15m]) > 3
```

---

## Threshold

```text
IS ABOVE 0
```

---

## Labels

| Label | Value |
|---|---|
| severity | critical |
| team | platform |

---

## Evaluation Settings

| Setting | Value |
|---|---|
| Evaluation Interval | 1 minute |
| Pending Period | 0 seconds |
| Keep Firing For | 0 seconds |

---

# Notification Contact Point

## Contact Point Name

task-2-55-contact-point

---

## Notification Channel

Slack

---

## Purpose

The Slack contact point is used to deliver Grafana alert notifications into the operational Slack channel.

This integration enables real-time alert visibility for platform monitoring and incident response.

---

# Slack Notification Validation

Slack notifications were successfully received for:

- Test alerts
- Firing alerts
- Resolved alerts

This confirms successful end-to-end integration between:

```text
Prometheus → Grafana Alerting → Slack
```

---

# Notification Policy Configuration

## Route Matcher

| Label | Value |
|---|---|
| severity | critical |

---

## Contact Point

task-2-55-contact-point

---

## Grouping Configuration

| Setting | Value |
|---|---|
| Group By | namespace, pod |
| Group Wait | 30 seconds |
| Group Interval | 5 minutes |
| Repeat Interval | 1 hour |

---

## Purpose

Notification policies route alerts to specific destinations based on labels.

Grouping reduces alert noise by combining related alerts together before sending notifications.

---

# Silence Configuration

## Silence Matcher

| Label | Value |
|---|---|
| team | platform |

---

## Duration

1 hour

---

## Purpose

Silences temporarily suppress alert notifications during:

- Maintenance windows
- Testing
- Operational activities

This helps reduce unnecessary notification noise while preserving internal alert evaluation.

---

# Inhibition Rule Design

## Objective

Suppress pod restart alerts when high CPU usage is already firing on the same node.

This prevents duplicate or misleading alerts caused by infrastructure resource pressure.

---

# Alertmanager Inhibition Rule

```yaml
inhibit_rules:
  - source_matchers:
      - alertname="task-2-55-cpu-alert"
      - severity="warning"

    target_matchers:
      - alertname="task-2-55-pod-restart-alert"

    equal:
      - instance
```

---

# Inhibition Rule Explanation

## Source Alert

task-2-55-cpu-alert

This is the inhibitor alert.

When this alert is firing, it can suppress downstream alerts.

---

## Target Alert

task-2-55-pod-restart-alert

This alert becomes suppressed when the source alert is active.

---

# Why This Inhibition Rule Matters

Pods may restart because the Kubernetes node is under heavy CPU pressure rather than because of an application defect.

If both alerts fire simultaneously, operators may receive duplicate alerts describing the same underlying infrastructure issue.

Inhibition reduces alert storms and improves operational signal quality.

---

# Purpose of the `equal` Field

```yaml
equal:
  - instance
```

The `equal` field ensures inhibition only occurs when both alerts belong to the same node or instance.

This is important because:

- A CPU alert on one node should not suppress pod restart alerts on unrelated nodes
- Inhibition must remain context-aware
- Suppression should only happen when alerts share the same infrastructure source

Without the `equal` field, a single high CPU alert could incorrectly suppress pod restart alerts across the entire cluster.

---

# Slack Alert Validation Results

The following alert behaviors were successfully validated:

| Validation | Result |
|---|---|
| Slack test notification | Success |
| Firing alert notification | Success |
| Resolved alert notification | Success |
| Notification routing | Success |
| Alert silencing | Success |

---

# Key Concepts Learned

- Grafana-managed alert rules
- PromQL alert queries
- Alert thresholds and evaluation behavior
- Slack notification integration
- Notification routing policies
- Alert grouping and repeat intervals
- Alert silences
- Alertmanager inhibition logic
- Alert noise reduction strategies

---

# Conclusion

In this task, Grafana alerting was configured using Prometheus metrics collected from Kubernetes infrastructure.

Alert rules were integrated with Slack notifications, grouped using notification policies, temporarily suppressed using silences, and documented with an Alertmanager inhibition rule design to improve operational monitoring quality and reduce alert fatigue.