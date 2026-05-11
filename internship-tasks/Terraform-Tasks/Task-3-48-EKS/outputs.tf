output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane"
  value       = module.eks.cluster_version
}

output "node_group_names" {
  description = "Managed node group names"
  value       = [for ng in module.eks.eks_managed_node_groups : ng.node_group_id]
}

output "cluster_iam_role_name" {
  description = "Cluster IAM role"
  value       = module.eks.cluster_iam_role_name
}

output "vpc_id" {
  description = "VPC hosting the cluster"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets used by the cluster and node group"
  value       = module.vpc.public_subnets
}

output "kubeconfig_command" {
  description = "Run this to wire kubectl to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}