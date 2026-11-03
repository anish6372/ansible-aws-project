variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_id" {
  description = "Subnet to place the instance in"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "root_volume_gb" {
  type    = number
  default = 12
}

variable "web_ingress_cidrs" {
  description = "CIDRs allowed to reach HTTP/HTTPS. Open to the world by default because this is a public website."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh" {
  description = "Open port 22 to operator_cidr. Prefer SSM Session Manager; SSH is only needed for Ansible over SSH."
  type        = bool
  default     = false
}

variable "operator_cidr" {
  description = "Your public IP as x.x.x.x/32. Only used when enable_ssh = true."
  type        = string
  default     = null

  validation {
    condition     = var.operator_cidr == null || can(cidrhost(var.operator_cidr, 0))
    error_message = "operator_cidr must be a valid CIDR such as 203.0.113.5/32."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name (only needed when enable_ssh = true)"
  type        = string
  default     = null
}

variable "role_tag" {
  description = "Value of the Role tag, used by the Ansible dynamic inventory"
  type        = string
  default     = "app"
}
