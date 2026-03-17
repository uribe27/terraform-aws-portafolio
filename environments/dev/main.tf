terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "portfolio-terraform-state-adur-dev"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "portfolio-terraform-locks-adur-dev"
  }
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  common_tags = {
    Project     = "portfolio"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "angel"
  }
}

module "networking" {
  source = "../../modules/networking"

  project     = "portfolio"
  environment = "dev"
  common_tags = local.common_tags

  vpc_cidr             = "10.0.0.0/26"
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.0.0.0/28", "10.0.0.16/28"]
  private_subnet_cidrs = ["10.0.0.32/28", "10.0.0.48/28"]

  enable_nat_gateway = true
}