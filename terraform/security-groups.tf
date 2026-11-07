# Security Groups for the ALB
resource "aws_security_group" "alb" {
  name        = "aws-terraform-infra-alb-sg"
  description = "Security group for the public ALB"
  vpc_id      = aws_vpc.main.id


  ingress = []
  egress  = []


  tags = {
    Name        = "aws-terraform-infra-alb-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Security Groups for ECS Fargate tasks
resource "aws_security_group" "fargate" {
  name        = "aws-terraform-infra-fargate-sg"
  description = "Security group for the ECS Fargate tasks"
  vpc_id      = aws_vpc.main.id


  ingress = []
  egress  = []


  tags = {
    Name        = "aws-terraform-infra-fargate-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Allow HTTP traffic from the Internet to the ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  # checkov:skip=CKV_AWS_260: Public HTTP ingress is intentional; the ALB listener redirects all HTTP requests to HTTPS
  security_group_id = aws_security_group.alb.id


  description = "Allow HTTP traffic from the Internet"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}


# Allow HTTPS traffic from the Internet to the ALB
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id


  description = "Allow HTTPS traffic from the Internet"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}


# Allow traffic from the ALB to the ECS Fargate tasks
resource "aws_vpc_security_group_ingress_rule" "fargate_from_alb" {
  security_group_id = aws_security_group.fargate.id


  description                  = "Allow application traffic from the ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}


# Allow the ALB to forward traffic to Fargate tasks
resource "aws_vpc_security_group_egress_rule" "alb_to_fargate" {
  security_group_id = aws_security_group.alb.id


  description                  = "Allow traffic to Fargate tasks on port 8000"
  referenced_security_group_id = aws_security_group.fargate.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}


# Security group for VPC Interface Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "aws-terraform-infra-vpc-endpoints-sg"
  description = "Security group for private VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id


  ingress = []
  egress  = []


  tags = {
    Name        = "aws-terraform-infra-vpc-endpoints-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Allow HTTPS traffic from Fargate tasks to interface endpoints
resource "aws_vpc_security_group_ingress_rule" "endpoints_from_fargate" {
  security_group_id = aws_security_group.vpc_endpoints.id


  description                  = "Allow HTTPS from Fargate tasks"
  referenced_security_group_id = aws_security_group.fargate.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


# Allow HTTPS traffic from Fargate tasks to interface endpoints
resource "aws_vpc_security_group_egress_rule" "fargate_to_endpoints" {
  security_group_id = aws_security_group.fargate.id


  description                  = "Allow HTTPS to private AWS Interface Endpoints"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}


# Allow HTTPS traffic from Fargate tasks to S3
resource "aws_vpc_security_group_egress_rule" "fargate_to_s3" {
  security_group_id = aws_security_group.fargate.id


  description    = "Allow HTTPS traffic to S3 through the Gateway Endpoint"
  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id
  from_port      = 443
  to_port        = 443
  ip_protocol    = "tcp"
}


# Restrict the default Security Group of the VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id


  ingress = []
  egress  = []


  revoke_rules_on_delete = true


  tags = {
    Name        = "aws-terraform-infra-default-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Security group for RDS database
resource "aws_security_group" "rds" {
  name        = "aws-terraform-infra-rds-sg"
  description = "Security group for private RDS database"
  vpc_id      = aws_vpc.main.id


  ingress = []
  egress  = []


  tags = {
    Name        = "aws-terraform-infra-rds-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Allow Fargate traffic to RDS PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "rds_from_fargate" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow Fargate traffic to RDS PostgreSQL"
  referenced_security_group_id = aws_security_group.fargate.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# Allow Fargate to connect to RDS PostgreSQL
resource "aws_vpc_security_group_egress_rule" "fargate_to_rds" {
  security_group_id = aws_security_group.fargate.id

  description                  = "Allow Fargate to connect to RDS PostgreSQL"
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}