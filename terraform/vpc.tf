# Main VPC
resource "aws_vpc" "main" {
  # checkov:skip=CKV2_AWS_11: VPC Flow Logs deferred for the cost-conscious demo environment; network traffic analysis is not required yet
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name        = "aws-terraform-infra-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Select two Availability Zones
locals {
  availability_zones = ["eu-west-3a", "eu-west-3b"]
}


# Public Subnets across 2 Availability Zones
resource "aws_subnet" "public" {
  count = 2


  vpc_id                  = aws_vpc.main.id
  cidr_block              = ["10.0.1.0/24", "10.0.2.0/24"][count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "aws-terraform-infra-public-${count.index + 1}"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Tier        = "public"
  }
}

# Private Subnets across 2 Availability Zones
resource "aws_subnet" "private" {
  count = 2


  vpc_id            = aws_vpc.main.id
  cidr_block        = ["10.0.11.0/24", "10.0.12.0/24"][count.index]
  availability_zone = local.availability_zones[count.index]


  tags = {
    Name        = "aws-terraform-infra-private-${count.index + 1}"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Tier        = "private"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name        = "aws-terraform-infra-igw"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "aws-terraform-infra-public-rt"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Tier        = "public"
  }
}


#Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name        = "aws-terraform-infra-private-rt"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
    Tier        = "private"
  }
}


# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = 2


  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = 2


  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}