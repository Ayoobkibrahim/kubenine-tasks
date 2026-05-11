data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "task-3-48"

  common_tags = {
    Project     = "task-3-48-eks"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  cluster_subnet_tag_key = "kubernetes.io/cluster/${var.cluster_name}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  igw_tags = {
    Name = "${local.name_prefix}-igw"
  }

  public_subnet_tags = {
    Name                            = "${local.name_prefix}-public-subnet"
    "kubernetes.io/role/elb"        = "1"
    (local.cluster_subnet_tag_key)  = "shared"
  }

  tags = local.common_tags
}