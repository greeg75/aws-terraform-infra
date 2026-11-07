# Secrets Manager secret for the application database URL
resource "aws_secretsmanager_secret" "app_database_url" {
  # checkov:skip=CKV_AWS_149: AWS-managed encryption is sufficient for the demo; no customer-managed KMS key is required
  # checkov:skip=CKV2_AWS_57: Automatic rotation deferred until a PostgreSQL-compatible rotation workflow is implemented and tested
  name        = "aws-terraform-infra/app/database-url"
  description = "PostgreSQL connection URL used by the ECS application"

  tags = {
    Name        = "aws-terraform-infra-app-database-url"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}
