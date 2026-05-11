module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name    = "task-2-34-cluster"
  cluster_version = "1.35"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  
  create_iam_role = false
  iam_role_arn    = aws_iam_role.cluster_role.arn


  authentication_mode = "API_AND_CONFIG_MAP"


  eks_managed_node_groups = {
    task-2-34-node-group = {
      name = "task-2-34-node-group"
      use_name_prefix = false
      
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      subnet_ids = module.vpc.public_subnets

      iam_role_arn = aws_iam_role.node_role.arn

      ami_type = "AL2023_x86_64_STANDARD"
    }
  }

  tags = {
    Name = "task-2-34-eks"
  }
}