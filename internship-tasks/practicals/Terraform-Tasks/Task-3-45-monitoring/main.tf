provider "aws" {
  region = var.region
}


data "terraform_remote_state" "task_3_44" {
  backend = "s3"

  config = {
    bucket = "task-3-41-tf-state-aki"
    key    = "task-3-44-ec2/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "aws_ssm_parameter" "slack_webhook" {
  name            = "/task-3-45/slack-webhook-url"
  with_decryption = true
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "6.0.0"

  sns_topic_name = "task-3-45-slack-alerts"

  slack_webhook_url = data.aws_ssm_parameter.slack_webhook.value
  slack_channel     = var.slack_channel
  slack_username    = "task-3-45-alert"

  lambda_function_name = "task-3-45-notify-slack"

}


resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "task-3-45-cpu-alarm-nginx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold

  alarm_description = "CPU exceeds threshold"

  dimensions = {
    InstanceId = data.terraform_remote_state.task_3_44.outputs.instance_id
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
}