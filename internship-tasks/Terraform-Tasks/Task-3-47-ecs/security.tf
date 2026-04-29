resource "aws_security_group" "alb" {
  name        = "task-3-47-alb-sg"
  description = "ALB security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "task-3-47-alb-sg"
  })
}

resource "aws_security_group" "ecs" {
  name        = "task-3-47-ecs-sg"
  description = "ECS service security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Streamlit traffic from ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound for image pulls/logs/SSM/S3"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "task-3-47-ecs-sg"
  })
}