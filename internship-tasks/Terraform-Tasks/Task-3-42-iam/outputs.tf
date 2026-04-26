output "role_arn" {
  value = aws_iam_role.task-3-42-app-role.arn
}

output "custom_policy_arn" {
  value = aws_iam_policy.task-3-42-custom-s3-policy.arn
}