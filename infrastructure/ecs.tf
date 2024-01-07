resource "aws_ecs_cluster" "cluster" {
name = "${var.application_name}-cluster"
}

resource "aws_ecs_service" "service" {
  name = "${var.application_name}-service"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.laravel_app.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 30

  network_configuration {
    subnets          = [aws_subnet.public_subnet_az_a.id, aws_subnet.public_subnet_az_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name = "${var.application_name}-container"
    container_port   = 80
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

variable "laravel_app_key" {
  type = string
}

resource "aws_ecs_task_definition" "laravel_app" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name = "aws-ccp-laravel-app"
      image = "ghcr.io/matthiasweiss/aws-ccp-laravel:main"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        },
      ]
      environment = [
        {
          name  = "FORCE_REDEPLOYMENT",
          value = timestamp()
        },
        {
          name  = "APP_URL",
          value = "https://${aws_lb.alb.dns_name}"
        },
        {
          name  = "APP_DEBUG",
          value = "true" # set to false for real deployment
        },
        {
          name  = "APP_ENV",
          value = "development" # set to "production" for real deployment
        },
        {
          name  = "APP_KEY",
          value = var.laravel_app_key
        },
        {
          name  = "DB_CONNECTION",
          value = "mysql"
        },
        {
          name  = "DB_HOST",
          value = aws_db_instance.mariadb.address
        },
        {
          name  = "DB_PORT",
          value = format("%s", aws_db_instance.mariadb.port)
        },
        {
          name  = "DB_DATABASE",
          value = var.rds_database
        },
        {
          name  = "DB_USERNAME",
          value = aws_db_instance.mariadb.username
        },
        {
          name  = "DB_PASSWORD",
          value = var.rds_password
        },
        {
          name  = "OCTANE_HTTPS",
          value = "true"
        },
        {
          name  = "SESSION_SECURE_COOKIE",
          value = "true"
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "ecs_server_allow_outbound" {
  description       = "All outbound"
  security_group_id = aws_security_group.ecs_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_server_allow_inbound_from_alb" {
  security_group_id        = aws_security_group.ecs_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.alb_sg.id
}