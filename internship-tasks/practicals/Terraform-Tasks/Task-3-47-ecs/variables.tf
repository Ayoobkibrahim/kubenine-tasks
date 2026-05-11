variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "streamlit_image" {
  description = "Streamlit container image"
  type        = string
}

variable "app_port" {
  description = "Streamlit app port"
  type        = number
  default     = 8501
}

variable "service_desired_count" {
  description = "Desired ECS tasks"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "Fargate task CPU"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory"
  type        = number
  default     = 512
}

variable "slack_channel" {
  description = "Slack channel for alerts"
  type        = string
  default     = "#task-3-47-alerts"
}

variable "slack_webhook_ssm_parameter_name" {
  description = "SSM parameter name storing Slack webhook URL"
  type        = string
  default     = "/task-3-47/slack-webhook-url"
}

variable "cpu_alarm_threshold" {
  description = "CPU alarm threshold percentage"
  type        = number
  default     = 2
}

variable "memory_alarm_threshold" {
  description = "Memory alarm threshold percentage"
  type        = number
  default     = 2
}

variable "s3_bucket_name" {
  description = "S3 bucket used by Streamlit app"
  type        = string
}

variable "ssm_parameter_arns_for_app" {
  description = "Exact SSM parameter ARNs read by app at runtime"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "Dev"
}