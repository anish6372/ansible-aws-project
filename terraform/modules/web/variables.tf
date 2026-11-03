variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets for the ALB and the instances (2+ AZs)"
  type        = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "web_ingress_cidrs" {
  description = "CIDRs allowed to reach the load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type    = string
  default = "app"
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN with the generated DB credentials (JSON with a password key)"
  type        = string
}

variable "domain_name" {
  description = "Optional. When set together with hosted_zone_id, HTTPS is enabled with an ACM certificate and HTTP redirects to it."
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  type    = string
  default = null
}
