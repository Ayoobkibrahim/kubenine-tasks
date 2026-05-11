module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a", "ap-south-1b"]

  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  public_subnet_tags_per_az = {
    "ap-south-1a" = {
      Name = "task-2-34-public-subnet-1"
    }
    "ap-south-1b" = {
      Name = "task-2-34-public-subnet-2"
    }
  }

  map_public_ip_on_launch = true

  enable_nat_gateway = false

  create_igw = true

  igw_tags = {
    Name = "task-2-34-igw"
  }

  tags = {
    Name = "task-2-34-vpc"
  }
}