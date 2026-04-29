*. CloudWatch Alarms

1. What is a CloudWatch alarm? :  
A CloudWatch alarm continuously monitors a specific AWS metric and automatically initiates an action (like sending a notification or scaling resources) if the metric crosses a predefined threshold.

2. Metric alarms vs. composite alarms : 
A metric alarm monitors a single metric's value (like CPU utilization), whereas a composite alarm watches the states of multiple other alarms and only triggers when a specific combination of them goes off, helping to reduce alert fatigue.

3. Alarm states :  
An alarm is in the OK state when the metric is within normal limits, ALARM when the defined threshold has been breached, and INSUFFICIENT_DATA when AWS doesn't have enough recent metric points to determine the state.

4. Evaluation periods and thresholds :  
The threshold is the specific numerical value the metric must cross to be considered a problem. The evaluation period defines how many consecutive data points (or how much time) the metric must stay beyond that threshold before the alarm officially triggers.

5. aws_cloudwatch_metric_alarm resource : 
This Terraform resource allows you to provision an alarm as code, defining exactly what metric to watch, the failure thresholds, and the actions to take when the alarm state changes.



*. SNS (Simple Notification Service)

1. What is SNS and the notification pipeline? :  
SNS is a highly available, managed messaging service that acts as a central hub for broadcasting messages. In an alert pipeline, CloudWatch sends a single notification to SNS, which then distributes that alert to multiple downstream services or users simultaneously.

2. Topics and subscriptions :  
An SNS "Topic" acts as a logical communication channel where publishers send messages. "Subscriptions" define the specific endpoints (like an email address, SMS number, or Lambda function) that are authorized to receive messages from that topic.

3. How notify-slack uses SNS as glue :  
The module sets up an SNS topic specifically to catch CloudWatch alerts. SNS acts as the "glue" by instantly triggering a subscribed Lambda function the moment an alert arrives, bridging the gap between AWS monitoring and Slack.



*. Slack Notification Module

1. terraform-aws-modules/notify-slack/aws :  
This public module automatically provisions the necessary serverless infrastructure—including an SNS topic, IAM roles, and a Python Lambda function—required to securely forward AWS alerts to a Slack workspace.

2. The pipeline :  
A breaching CloudWatch Alarm publishes a message to an SNS Topic, which immediately triggers a Lambda function; the Lambda then formats the raw AWS JSON data into a readable message and posts it via an HTTP POST request to a Slack Webhook.

3. Module inputs :  
slack_webhook_url is the secure, unique URL provided by Slack to receive external messages, slack_channel dictates which specific chat room the alert appears in, and sns_topic_name sets the name for the SNS hub receiving the AWS alerts.



*. SSM Parameter Store

1. What is SSM Parameter Store? :  
AWS Systems Manager (SSM) Parameter Store is a secure, managed service used to centrally store configuration data and secrets, allowing you to separate sensitive values from your source code.

2. SecureString vs. String :  
A String parameter is stored in plain text and is useful for generic configuration data (like environment names). A SecureString encrypts the value using AWS KMS, making it the required choice for API keys, passwords, and webhook URLs.

3. data "aws_ssm_parameter" :  
This Terraform data source dynamically pulls existing values from the Parameter Store during the "plan" or "apply" phase. This allows your code to reference a secret (like a Slack webhook) without you ever typing the actual secret into your code.

4. Why secrets shouldn't be in code (and limitations) : 
Hardcoding secrets in Terraform files exposes them to anyone who has access to your version control system (like GitHub). However, even when fetching secrets dynamically via SSM, it's critical to secure your backend storage, because Terraform often saves the fetched secret in plain text within the terraform.tfstate file.