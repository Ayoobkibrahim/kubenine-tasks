
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "task-3-47"

  common_tags = {
    Project     = "task-3-47-ecs"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"


  name = "task-3-47-vpc"
  cidr = "10.0.0.0/16"


  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]


  enable_nat_gateway = true
  single_nat_gateway = true


  enable_dns_hostnames = true
  enable_dns_support   = true

  igw_tags = {
    Name = "task-3-47-igw"
  }

  nat_gateway_tags = {
    Name = "task-3-47-nat"
  }

  public_subnet_tags = {
    Name = "task-3-47-public-subnet"
  }

  private_subnet_tags = {
    Name = "task-3-47-private-subnet"
  }

  tags = local.common_tags
}