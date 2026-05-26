############################################
# VPC 
############################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "task-4-2-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "task-4-2-vpc"
  }
}

############################################
# SECURITY GROUP 
############################################

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "task-4-2-web-sg"
  description = "Security group for ALB and EC2"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    "http-80-tcp",
    "ssh-tcp"
  ]

  ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]

  egress_rules = [
    "all-all"
  ]

  tags = {
    Name = "task-4-2-web-sg"
  }
}

############################################
# EC2 
############################################

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "task-4-2-ec2"

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    module.web_sg.security_group_id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Task 4.2 WAF Test Server" > /var/www/html/index.html
              EOF

  tags = {
    Name = "task-4-2-ec2"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################
# ALB 
############################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.9.0"

  name               = "task-4-2-test-alb"
  load_balancer_type = "application"

  vpc_id = module.vpc.vpc_id

  subnets = module.vpc.public_subnets

  security_groups = [
    module.web_sg.security_group_id
  ]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web"
      }
    }
  }

  target_groups = {
    web = {
      name_prefix       = "web"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled  = true
        path     = "/"
        port     = "traffic-port"
        protocol = "HTTP"
      }
    }
  }

  tags = {
    Name = "task-4-2-test-alb"
  }
}

############################################
# TARGET GROUP ATTACHMENT
############################################

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = module.alb.target_groups["web"].arn
  target_id        = module.ec2_instance.id
  port             = 80
}