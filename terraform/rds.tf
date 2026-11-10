# RDS DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "aws-terraform-infra-db-subnet-group"
  description = "Private subnets for RDS PostgreSQL"

  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "aws-terraform-infra-db-subnet-group"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Primary PostgreSQL Database
resource "aws_db_instance" "primary" {
  # checkov:skip=CKV_AWS_118: Enhanced Monitoring deferred to limit costs in the demo environment
  # checkov:skip=CKV_AWS_129: RDS log exports deferred; CloudWatch ingestion and storage costs are not justified for the initial demo
  # checkov:skip=CKV_AWS_157: A cross-AZ read replica is used for the demo; automatic Multi-AZ failover is not required
  # checkov:skip=CKV_AWS_161: The application currently uses password-based PostgreSQL authentication with a dedicated SQL user
  # checkov:skip=CKV_AWS_353: Performance Insights deferred to limit costs in the demo environment
  # checkov:skip=CKV2_AWS_30: PostgreSQL query logging deferred to avoid additional log ingestion and potential sensitive-data exposure
  identifier = "aws-terraform-infra-postgres-primary"

  engine         = "postgres"
  engine_version = "18.3"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "appdb"
  username = "dbadmin"
  password = var.db_master_password
  port     = 5432

  availability_zone    = "eu-west-3a"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection = false
  skip_final_snapshot = true

  copy_tags_to_snapshot = true

  tags = {
    Name        = "aws-terraform-infra-postgres-primary"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Role        = "primary"
  }
}


# PostgreSQL Read Replica
resource "aws_db_instance" "replica" {
  # checkov:skip=CKV_AWS_118: Enhanced Monitoring deferred to limit costs in the demo environment
  # checkov:skip=CKV_AWS_129: RDS log exports deferred; CloudWatch ingestion and storage costs are not justified for the initial demo
  # checkov:skip=CKV_AWS_157: This is a read replica in a separate AZ, not a Multi-AZ automatic failover deployment
  # checkov:skip=CKV_AWS_353: Performance Insights deferred to limit costs in the demo environment
  identifier = "aws-terraform-infra-postgres-replica"

  replicate_source_db = aws_db_instance.primary.arn

  instance_class    = "db.t4g.micro"
  storage_encrypted = true

  availability_zone = "eu-west-3b"

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  auto_minor_version_upgrade = true
  apply_immediately          = true

  deletion_protection = false
  skip_final_snapshot = true

  copy_tags_to_snapshot = true

  tags = {
    Name        = "aws-terraform-infra-postgres-replica"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Role        = "read-replica"
  }
}