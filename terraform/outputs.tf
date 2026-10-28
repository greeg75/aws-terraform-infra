output "aws_region" {
  description = "AWS region configured for this project"
  value       = var.aws_region
}


output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}


output "ecr_repository_url" {
  description = "URL of the ECR repository for Docker image pushes"
  value       = aws_ecr_repository.app.repository_url
}
