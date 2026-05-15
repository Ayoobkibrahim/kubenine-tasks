module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  iam_role_name            = "task-3-48-cluster-role"
  iam_role_use_name_prefix = false

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = [var.instance_type]
  }

  eks_managed_node_groups = {
    "task-3-48-node-group" = {
      name = "task-3-48-node-group"

      subnet_ids = module.vpc.public_subnets

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = [var.instance_type]
      capacity_type  = "ON_DEMAND"

      iam_role_name              = "task-3-48-node-role"
      iam_role_use_name_prefix   = false
      iam_role_attach_cni_policy = true
    }
  }

  tags = {
    Project     = "task-3-48-eks"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}