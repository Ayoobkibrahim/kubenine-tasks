module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "task-3-47-alb"
  load_balancer_type = "application"
  internal           = false

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.alb.id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "task-3-47-tg"
      }
    }
  }

  target_groups = {
    task-3-47-tg = {
      name_prefix       = "t347-"
      protocol          = "HTTP"
      port              = var.app_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        protocol            = "HTTP"
        path                = "/_stcore/health"
        matcher             = "200-399"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
        timeout             = 5
      }
    }
  }

  tags = local.common_tags
}