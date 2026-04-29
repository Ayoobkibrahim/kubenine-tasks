data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "task_key" {
  key_name   = "task-3-46-key"
  public_key = file(pathexpand(var.public_key_path))
}

module "ec2_1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name          = "task-3-46-nginx-1"
  instance_type = var.instance_type
  ami           = data.aws_ami.al2023.id
  subnet_id     = module.vpc.private_subnets[0]

  create_security_group      = false
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false

  key_name = aws_key_pair.task_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y nginx
    systemctl enable --now nginx
    echo "Instance 1 - task-3-46" > /usr/share/nginx/html/index.html
  EOF
}

module "ec2_2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name          = "task-3-46-nginx-2"
  instance_type = var.instance_type
  ami           = data.aws_ami.al2023.id
  subnet_id     = module.vpc.private_subnets[1]

  create_security_group      = false
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false

  key_name = aws_key_pair.task_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y nginx
    systemctl enable --now nginx
    echo "Instance 2 - task-3-46" > /usr/share/nginx/html/index.html
  EOF
}