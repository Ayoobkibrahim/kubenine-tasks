resource "aws_cloudwatch_log_group" "streamlit_logs" {
  name              = "/ecs/task-3-47-streamlit-task"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "task-3-47-streamlit-task-logs"
  })
}

resource "aws_ecs_cluster" "this" {
  name = "task-3-47-cluster"

  tags = merge(local.common_tags, {
    Name = "task-3-47-cluster"
  })
}

resource "aws_ecs_task_definition" "streamlit" {
  family                   = "task-3-47-streamlit-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "streamlit-app"
      image     = var.streamlit_image
      essential = true

      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "STREAMLIT_SERVER_PORT"
          value = tostring(var.app_port)
        },
        {
          name  = "STREAMLIT_SERVER_ADDRESS"
          value = "0.0.0.0"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.streamlit_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "task-3-47-streamlit-task"
  })
}

resource "aws_ecs_service" "streamlit" {
  name            = "task-3-47-streamlit-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.streamlit.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["task-3-47-tg"].arn
    container_name   = "streamlit-app"
    container_port   = var.app_port
  }

  depends_on = [module.alb]

  tags = merge(local.common_tags, {
    Name = "task-3-47-streamlit-service"
  })
}