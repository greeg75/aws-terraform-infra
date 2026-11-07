# ECS Cluster
resource "aws_ecs_cluster" "main" {
  # checkov:skip=CKV_AWS_65: Container Insights deferred to limit additional CloudWatch costs in the demo environment
  name = "aws-terraform-infra-cluster"


  tags = {
    Name        = "aws-terraform-infra-cluster"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "aws-terraform-infra"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"


  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  volume {
    name = "tmp"
  }

  container_definitions = jsonencode([
    {
      name      = "aws-terraform-infra-app"
      image     = "923819676616.dkr.ecr.eu-west-3.amazonaws.com/aws-terraform-infra:7d492effa938abf424ccbb867bd85c0133cba79f"
      essential = true


      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.app_database_url.arn
        }
      ]
      readonlyRootFilesystem = true


      mountPoints = [
        {
          sourceVolume  = "tmp"
          containerPath = "/tmp"
          readOnly      = false
        }
      ]


      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])


  tags = {
    Name        = "aws-terraform-infra-task"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# ECS Service
resource "aws_ecs_service" "app" {
  name            = "aws-terraform-infra-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 0
  launch_type     = "FARGATE"


  platform_version = "LATEST"


  health_check_grace_period_seconds = 60


  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = false
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "aws-terraform-infra-app"
    container_port   = 8000
  }


  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_iam_role_policy.ecs_secrets_access,
    aws_vpc_endpoint.secrets_manager,
    aws_lb_listener.https
  ]


  tags = {
    Name        = "aws-terraform-infra-service"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}
