terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "task-3-41-tf-state-aki"
    key    = "task-3-43-vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


resource "aws_key_pair" "task-3-44-key" {
  key_name   = "task-3-44-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "task-3-44-nginx-sg" {
  name   = "task-3-44-nginx-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name = "task-3-44-nginx"

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.task-3-44-nginx-sg.id
  ]

  key_name = aws_key_pair.task-3-44-key.key_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
}