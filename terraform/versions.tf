terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  backend "s3" {
    bucket       = "aws-terraform-infra-tfstate-greg75"
    key          = "aws-terraform-infra/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
