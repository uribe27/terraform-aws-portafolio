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

module "security" {
  source = "../../modules/security"

  project     = "portfolio"
  environment = "dev"
  common_tags = local.common_tags

  vpc_id   = module.networking.vpc_id
  app_port = 8080
}

module "compute" {
  source = "../../modules/compute"

  project = "portfolio"
  environment = "dev"
  common_tags = local.common_tags

  # Red — outputs del módulo networking
  vpc_id = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  # Seguridad — outputs del módulo security
  sg_alb_id = module.security.sg_alb_id
  sg_ec2_id = module.security.sg_ec2_id
  ec2_instance_profile_name = module.security.ec2_instance_profile_name

  # Instancia — Amazon Linux 2023 en eu-west-1
  ami_id = "ami-0d940f23d527c3ab1"
  instance_type = "t3.micro"
  app_port = 8080

  # ASG en dev: mínimo 1, máximo 2, deseado 1
  asg_min_size = 1
  asg_max_size = 2
  asg_desired_capacity = 1
}
