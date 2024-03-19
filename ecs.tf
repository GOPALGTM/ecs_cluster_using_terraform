resource "aws_ecs_cluster" "main" {
  name = "django-app-cluster"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
}

resource "aws_security_group" "my_security_group" {
  name        = "terraform-security-group"
  description = "terraform security group to allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = toset(var.ingress_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "cb-app-task"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      name      = "nodebackend"
      image     = "225403229739.dkr.ecr.ap-south-1.amazonaws.com/nodebackend:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
    }
  ])
  depends_on = [data.aws_iam_role.ecs_task_execution_role]
}

resource "aws_ecs_service" "main" {
  name            = "cb-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.id
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.my_security_group.id]
    subnets          = [for subnet in data.aws_subnet.default : subnet.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.arn
    container_name   = "nodebackend"
    container_port   = var.app_port
  }
  depends_on = [aws_alb.main]
}
