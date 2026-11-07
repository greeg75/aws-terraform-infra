variable "aws_region" {
  description = "Region AWS where resources will be created"
  type        = string
  default     = "eu-west-3"
}

variable "db_master_password" {
  description = "Master password for RDS database"
  type        = string
  sensitive   = true
}
