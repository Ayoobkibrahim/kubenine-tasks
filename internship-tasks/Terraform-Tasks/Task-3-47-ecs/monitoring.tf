data "aws_ssm_parameter" "slack_webhook" {
  name            = var.slack_webhook_ssm_parameter_name
  with_decryption = true
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "6.0.0"

  sns_topic_name       = "task-3-47-slack-alerts"
  lambda_function_name = "task-3-47-notify-slack"

  slack_webhook_url = data.aws_ssm_parameter.slack_webhook.value
  slack_channel     = var.slack_channel
  slack_username    = "task-3-47-alert-bot"

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "task-3-47-cpu-alarm"
  alarm_description   = "ECS CPU utilization alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = "task-3-47-streamlit-service"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "task-3-47-memory-alarm"
  alarm_description   = "ECS Memory utilization alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = "task-3-47-streamlit-service"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
}