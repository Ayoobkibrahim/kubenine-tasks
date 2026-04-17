* CloudWatch Fundamentals

1. What CloudWatch is and what role it plays in AWS:
CloudWatch is the native monitoring, observability, and management service built into AWS. Its role is to act as the "eyes and ears" of your infrastructure, collecting data from all your AWS resources and applications in real-time to give you a unified view of your system's health.

2. The difference between metrics and logs:
Metrics are numerical data points measured over time (e.g., "CPU utilization is at 85%"). They are great for graphs and alarms. Logs are text-based records of specific events that happened in your application (e.g., "User Ayoob logged in at 10:42 AM" or "Database connection failed"). You use metrics to know when something is broken, and logs to figure out why.

3. What a namespace is and how metrics are organized:
A namespace is essentially a folder or container for metrics. AWS uses namespaces to keep metrics from different services isolated from each other. For example, all EC2 metrics live in the AWS/EC2 namespace, and all database metrics live in the AWS/RDS namespace.

4. Default vs. Custom metrics:
Default metrics are provided by AWS automatically without any setup (like EC2 CPU usage). Custom metrics are specific data points your own application code generates and pushes to CloudWatch (like "number of items added to a shopping cart" or "failed login attempts").



* Hypervisor-Level vs OS-Level Metrics

1. Why CPU, network, and disk I/O are available by default:
AWS runs your EC2 instances on a hypervisor (the physical host machine). The hypervisor can see exactly how much hardware CPU, network bandwidth, and raw disk operations your VM is consuming from the outside, so AWS provides these metrics automatically.

2. Why memory and disk usage are not — the virtualization boundary:
The hypervisor cannot look inside your operating system. For security and privacy, AWS does not know how your Linux or Windows OS is managing its internal RAM or how full its file system is. Therefore, memory utilization and disk space availability cannot be provided by default.

3. What the CloudWatch Agent does and why it exists:
Because AWS cannot see inside the OS, we must install the CloudWatch Agent directly onto the EC2 instance. This agent runs as a background service inside the OS, gathers those internal metrics (like RAM usage and disk space), and pushes them out to CloudWatch as Custom Metrics.



* CloudWatch Alarms

1. What an alarm is and how it evaluates a metric over time:
An alarm is a threshold watcher. You define a metric, a threshold, and a time period (e.g., "If CPU > 80% for 3 consecutive 5-minute periods"). The alarm constantly evaluates the incoming metric data points against this rule.

2. Alarm states: OK, ALARM, INSUFFICIENT_DATA:
* OK: The metric is operating normally within the safe threshold.

ALARM: The threshold has been breached, indicating a problem.

INSUFFICIENT_DATA: CloudWatch hasn't received enough data points to evaluate the rule, which usually happens right after a server boots up or if a custom metric stops reporting.

3. How alarms connect to SNS for notifications:
When an alarm transitions to the ALARM state, it triggers an SNS (Simple Notification Service) topic. SNS then broadcasts that alert to subscribers, sending an email to the team, a webhook to Slack, or triggering a PagerDuty call to the on-call engineer.

4. How alarms can trigger automated actions:
Alarms are the trigger for self-healing systems. Instead of just sending an alert, an alarm can directly command an Auto Scaling Group to launch more instances during a traffic spike, or tell EC2 to automatically reboot a frozen server.



* Monitoring as a Foundation

1. Why monitoring must exist before alerting or scaling
Monitoring provides the data and baseline truth needed to make informed decisions. Without monitoring to establish what 'normal' looks like, you cannot set accurate alarm thresholds for alerting or define the right triggers for automated scaling, leading to either missed failures or wasted costs.


2.How metrics feed into scaling policies, dashboards, and incident response
Metrics act as the foundational data that drive your entire cloud operations. They automatically trigger scaling policies when demand changes, provide the live data needed to visualize system health on dashboards, and give engineers the historical timeline required to quickly pinpoint root causes during incident response.


3.The Cost of Not Monitoring
Silent Failures: Without alarms tied to metrics, critical systems can crash without anyone knowing until customers start complaining.

Capacity Blindness: Without tracking metrics, you either run out of resources and crash, or you massively over-provision servers "just in case" and waste thousands of dollars.



* CloudWatch Logs Structure

1. What a Log Group is — a logical container for related logs
Log Group: "A Log Group is a logical container that groups related logs together—typically representing a specific application or service—sharing the same retention, monitoring, and access control settings."

2. What a Log Stream is — an individual source within a group (e.g., one EC2 instance)
Log Stream: "A Log Stream is an individual sequence of log events coming from a specific source within a Log Group, such as a single EC2 instance or a specific container."

3. How log groups and streams are organized
Organization: "The hierarchy follows a simple path: Log Groups contain multiple Log Streams, and each Log Stream contains the actual timestamped Log Events."


* Centralized Logging

1. Why logs must be centralized, not scattered across instances 
Centralized logging aggregates data from various sources into one durable location, allowing you to analyze your entire infrastructure from a single pane of glass rather than checking individual servers.

2. What happens to logs when an ASG-managed instance is terminated
In an Auto Scaling Group (ASG), instances are temporary; centralizing logs ensures that when an instance is terminated, its logs are preserved in CloudWatch for troubleshooting instead of being deleted with the instance.

3. Why SSH-based debugging does not work at scale
SSH-based debugging fails at scale because it is impossible to manually log into hundreds of servers during an incident; centralized logging provides instant, searchable access to all logs simultaneously.



* CloudWatch Agent for Logs

1. How the agent ships log files to CloudWatch
The CloudWatch Agent is a service installed on your instance that monitors specific files (like /var/log/nginx/error.log) and pushes any new log entries to the CloudWatch service in real-time.

2. Configuring which files to collect and where to send them
You use a JSON configuration file to tell the agent exactly which local file paths to watch and which Log Group and Stream names they should be assigned to in AWS.

3. The difference between metric collection and log collection in the agent
Metrics vs. Logs Collection: "While the agent collects metrics to track numerical performance (like Memory usage), it collects logs to capture raw text events and error messages for deeper behavioral analysis."



* Log Retention & Search

1. Why retention policies matter for cost and compliance
Retention policies define how long logs are stored (ranging from 1 day to forever), helping organizations balance storage costs with legal or security compliance requirements.

2. How to search and filter within log groups
CloudWatch allows you to use 'Metric Filters' and 'Filter Patterns' to scan massive amounts of log data for specific keywords, such as 'Error' or 'Timeout,' to identify issues quickly.

3. Using filter patterns to find specific entries (errors, status codes, IPs)
Using filter patterns, you can extract specific data from your logs—like HTTP 500 status codes—and even turn those occurrences into numerical metrics for alerting.