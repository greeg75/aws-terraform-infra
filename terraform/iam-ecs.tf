# Trust policy for ECS Task Execution Role
data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }


    actions = ["sts:AssumeRole"]
  }
}


# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name               = "aws-terraform-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json


  tags = {
    Name        = "aws-terraform-infra-ecs-execution-role"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Allow ECS Task Execution Role to retrieve the application database URL
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "aws-terraform-infra-secrets-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.app_database_url.arn
      }
    ]
  })
}