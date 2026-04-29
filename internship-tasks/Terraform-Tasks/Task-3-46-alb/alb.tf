module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = "task-3-46-alb"
  load_balancer_type = "application"
  internal           = false

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  create_security_group      = false
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false

  target_groups = {
    tg = {
      name              = "task-3-46-tg"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled             = true
        protocol            = "HTTP"
        path                = "/"
        matcher             = "200"
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "tg"
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "ec2_1" {
  target_group_arn = module.alb.target_groups["tg"].arn
  target_id        = module.ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_2" {
  target_group_arn = module.alb.target_groups["tg"].arn
  target_id        = module.ec2_2.id
  port             = 80
}