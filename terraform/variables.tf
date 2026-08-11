variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (web + app)"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (database only)"
  default     = "10.0.2.0/24"
}

variable "operator_cidr" {
  description = "Your IP in CIDR notation for SSH access. Replace with your actual IP e.g. 203.0.113.5/32"
  default     = "119.82.111.214/32" # CHANGE THIS to your IP before deploying
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS (us-east-1)"
  default     = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_type" {
  description = "EC2 instance type for web and app servers"
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for the database server"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "rootkey"
}
