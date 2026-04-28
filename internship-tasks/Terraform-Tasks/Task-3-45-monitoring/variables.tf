variable "region" {
  default = "ap-south-1"
}

variable "slack_channel" {
  description = "Slack channel name"
  default = "#task-3-45-alerts"
}

variable "cpu_threshold" {
  description = "CPU alarm threshold"
  default     = 2
}