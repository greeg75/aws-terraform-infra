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

variable "app_image_tag" {
  description = "Tag (git SHA) of the application image to deploy from ECR"
  type        = string
}