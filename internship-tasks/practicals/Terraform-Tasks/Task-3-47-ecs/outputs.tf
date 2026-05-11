output "alb_dns_name" {
  description = "ALB DNS name for Streamlit app"
  value       = module.alb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = "task-3-47-streamlit-service"
}

output "task_execution_role_arn" {
  description = "Task execution role ARN"
  value       = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  description = "Task role ARN"
  value       = aws_iam_role.task_role.arn
}

output "cpu_alarm_name" {
  description = "CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.cpu_alarm.alarm_name
}

output "memory_alarm_name" {
  description = "Memory alarm name"
  value       = aws_cloudwatch_metric_alarm.memory_alarm.alarm_name
}