# VPC Interface Endpoint for ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true


  tags = {
    Name        = "aws-terraform-infra-ecr-api-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# VPC Interface Endpoint for ECR Docker Registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true


  tags = {
    Name        = "aws-terraform-infra-ecr-dkr-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# VPC Interface Endpoint for Amazon CloudWatch logs
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true


  tags = {
    Name        = "aws-terraform-infra-cloudwatch-logs-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]


  tags = {
    Name        = "aws-terraform-infra-s3-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# VPC Interface Endpoint for AWS Secrets Manager
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "aws-terraform-infra-secrets-manager-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}