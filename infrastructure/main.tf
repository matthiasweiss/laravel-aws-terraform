terraform {
  backend "s3" {
    bucket  = "${var.application_name}-terraform"
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

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

provider "aws" {
  region = var.aws_region
}

variable "application_name" {
  type = string
  default = "aws-ccp-laravel"
}
