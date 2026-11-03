# Prod-like environment: ALB + Auto Scaling Group across 2 AZs, RDS in private subnets, CloudWatch alarms.
# No NAT gateway (saves about $32/month): instances sit in public subnets but their security group only
# admits the load balancer. See docs/architecture.md for the trade-off.
#
# Cost: about $0.10-0.15/hour while running. Apply for a demo, then `terraform destroy`.

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

module "network" {
  source = "../../modules/network"

  name     = var.project
  vpc_cidr = var.vpc_cidr
  az_count = 2
}

module "database" {
  source = "../../modules/database"

  name                      = var.project
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.private_subnet_ids
  allowed_security_group_id = module.web.app_security_group_id
  multi_az                  = var.rds_multi_az
  backup_retention_days     = var.rds_backup_days
}

module "web" {
  source = "../../modules/web"

  name              = var.project
  vpc_id            = module.network.vpc_id
  vpc_cidr          = module.network.vpc_cidr
  public_subnet_ids = module.network.public_subnet_ids
  instance_type     = var.instance_type
  min_size          = var.min_size
  desired_size      = var.desired_size
  max_size          = var.max_size

  db_host       = module.database.endpoint
  db_secret_arn = module.database.master_secret_arn

  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}

module "observability" {
  source = "../../modules/observability"

  name                    = var.project
  alb_arn_suffix          = module.web.alb_arn_suffix
  target_group_arn_suffix = module.web.target_group_arn_suffix
  asg_name                = module.web.asg_name
  db_identifier           = "${var.project}-db"
  alarm_email             = var.alarm_email
}
