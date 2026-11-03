terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial config: supply bucket/region with
  #   terraform init -backend-config=backend.hcl
  # (see backend.hcl.example). CI uses `init -backend=false` for validation.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

module "network" {
  source = "../../modules/network"

  name             = var.project
  vpc_cidr         = var.vpc_cidr
  az_count         = var.high_availability ? 2 : 1
  enable_nat       = var.enable_nat
  enable_flow_logs = var.enable_flow_logs
}

module "compute" {
  source = "../../modules/compute"

  name          = var.project
  vpc_id        = module.network.vpc_id
  vpc_cidr      = module.network.vpc_cidr
  subnet_id     = module.network.public_subnet_ids[0]
  instance_type = var.instance_type

  enable_ssh    = var.enable_ssh
  operator_cidr = var.operator_cidr
  key_name      = var.key_name
}

# Optional managed database. Off by default: the dev profile runs PostgreSQL on the app host.
# RDS needs subnets in 2 AZs, so enabling it requires high_availability = true.
module "database" {
  count  = var.enable_rds ? 1 : 0
  source = "../../modules/database"

  name                      = var.project
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.private_subnet_ids
  allowed_security_group_id = module.compute.security_group_id
  multi_az                  = var.rds_multi_az
}
