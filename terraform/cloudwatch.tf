# CloudWatch Log Group for ECS application
resource "aws_cloudwatch_log_group" "app" {
  # checkov:skip=CKV_AWS_158: CloudWatch-managed encryption is sufficient for the demo; no customer-managed KMS key is required
  # checkov:skip=CKV_AWS_338: Thirty-day retention is intentional for the demo environment to limit log storage costs
  name              = "/ecs/aws-terraform-infra"
  retention_in_days = 30


  tags = {
    Name        = "aws-terraform-infra-logs"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}