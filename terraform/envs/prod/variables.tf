variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "Name prefix. Differs from dev so both can coexist."
  type        = string
  default     = "multitier-prod"
}

variable "vpc_cidr" {
  description = "Different range from dev (10.0.0.0/16) to allow peering later"
  type        = string
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "rds_multi_az" {
  description = "Doubles database cost; enable only for a short failover demo"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Email for alarm notifications (optional)"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Optional. Enables HTTPS via ACM when set together with hosted_zone_id"
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  type    = string
  default = null
}

variable "rds_backup_days" {
  description = "Free-tier accounts cap this at 1. Use 7+ on a paid account."
  type        = number
  default     = 1
}
