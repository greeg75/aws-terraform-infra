resource "aws_ecr_repository" "app" {
  name                 = "aws-terraform-infra"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false


  image_scanning_configuration {
    scan_on_push = true
  }


  encryption_configuration {
    encryption_type = "KMS"
  }


  lifecycle {
    prevent_destroy = true
  }


  tags = {
    Name        = "aws-terraform-infra"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name


  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the 10 most recent tagged images"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}