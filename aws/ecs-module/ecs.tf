# ECS 

########## log group ##########
resource "aws_cloudwatch_log_group" "lg" {
  name = "${var.app_name}-${var.app_env}-logs"

  tags = {
    Name        = var.app_name
    Environment = var.app_env
  }
}

########## Create Cluster ##########
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-${var.app_env}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.lg.name
      }
    }
  }

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.app_env
  }
}

resource "aws_ecs_cluster_capacity_providers" "provider" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

########## Task Defination ##########
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  container_definitions    = <<CONTAINER_DEFINITION
    [
    {
        "name": "${var.app_name}-backend",
        "image": "${aws_ecr_repository.ecr.repository_url}:backend",
        "cpu": 0,
        "portMappings": [
        {
            "containerPort": ${var.container_port},
            "hostPort": ${var.container_port},
            "protocol": "tcp",
            "name": "backend-80-tcp",
            "appProtocol": "http"
        }
        ],
        "essential": true,
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.lg.name}",
            "awslogs-region": "ap-northeast-3",
            "awslogs-stream-prefix": "ecs-task"
        }
        }
    }
    ]

    CONTAINER_DEFINITION
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = {
    Name        = "${var.app_name}-task"
    Environment = var.app_env
  }
}

########## ECS service ##########
resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.app_env}-ecs-service"
  cluster              = aws_ecs_cluster.cluster.id
  task_definition      = "${aws_ecs_task_definition.backend.family}:${aws_ecs_task_definition.backend.revision}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-backend"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.listener]
}

########## security group ##########
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb-sg.id]
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_env
  }
}