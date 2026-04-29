module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "task-3-46-vpc"
  cidr = "10.46.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.46.1.0/24", "10.46.2.0/24"]
  private_subnets = ["10.46.11.0/24", "10.46.12.0/24"]

  public_subnet_names  = ["task-3-46-public-subnet-a", "task-3-46-public-subnet-b"]
  private_subnet_names = ["task-3-46-private-subnet-a", "task-3-46-private-subnet-b"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  igw_tags = {
    Name = "task-3-46-igw"
  }

  nat_gateway_tags = {
    Name = "task-3-46-nat"
  }

  tags = {
    Project = "task-3-46-alb"
  }
}