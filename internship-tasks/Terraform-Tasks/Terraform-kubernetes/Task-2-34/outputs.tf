
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}


output "cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  description = "EKS Node IAM Role ARN"
  value       = aws_iam_role.node_role.arn
}


output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API Server Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Cluster Security Group ID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes Version"
  value       = module.eks.cluster_version
}


output "node_group_name" {
  description = "EKS Node Group Name"
  value       = "task-2-34-node-group"
}


output "kubeconfig_command" {
  description = "Command to connect kubectl"
  value       = "aws eks update-kubeconfig --region ap-south-1 --name task-2-34-cluster"
}