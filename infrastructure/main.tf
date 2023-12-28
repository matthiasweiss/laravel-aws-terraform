
terraform {
  backend "s3" {
    bucket  = "aws-ccp-laravel-terraform"
    key     = "terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/24"
}

# Password is stored in TF_VAR_rds_password environment variable
variable "rds_password" {
  type = string
}

resource "aws_db_instance" "mariadb" {
  allocated_storage    = 20
  db_name              = "aws-ccp-laravel"
  engine               = "mariadb"
  engine_version       = "10.6.14"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = var.rds_password
  db_subnet_group_name = aws_vpc.default_vpc.cidr_block
}

resource "aws_ecs_task_definition" "webserver" {
  family = "service"
  container_definitions = jsonencode([
    {
      name                     = "webserver"
      image                    = "https://ghcr.io/matthiasweiss/aws-ccp-laravel:main"
      requires_compatibilities = "FARGATE"
      cpu                      = 10
      memory                   = 512
    }
  ])
}
