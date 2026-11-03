variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "Name prefix and Project tag"
  type        = string
  default     = "multitier"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# ---- Cost profile switches (see docs/cost.md) ----
variable "high_availability" {
  description = "Span 2 AZs. Required for RDS. Costs nothing by itself."
  type        = bool
  default     = false
}

variable "enable_nat" {
  description = "NAT gateway for private subnets (about $32/month)"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Use RDS PostgreSQL instead of PostgreSQL on the app host"
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_rds || var.high_availability
    error_message = "enable_rds requires high_availability = true (RDS subnet groups need subnets in 2 AZs)."
  }
}

variable "rds_multi_az" {
  type    = bool
  default = false
}

variable "enable_flow_logs" {
  type    = bool
  default = false
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# ---- Access ----
variable "enable_ssh" {
  description = "Allow SSH from operator_cidr (needed for Ansible over SSH). Leave false and use SSM when possible."
  type        = bool
  default     = false
}

variable "operator_cidr" {
  description = "Your public IP as x.x.x.x/32"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Existing EC2 key pair name (create it in the console or with aws ec2 create-key-pair)"
  type        = string
  default     = null
}
