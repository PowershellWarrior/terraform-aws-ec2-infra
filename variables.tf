
variable "aws_region" {
  description = "AWS region where all resources will be provisioned"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type — t2.micro is free tier eligible"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the existing EC2 Key Pair for SSH access"
  type        = string
}

variable "your_ip_cidr" {
  description = "Your public IP in CIDR notation — restricts SSH to your machine only"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet inside the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "project_name" {
  description = "Name tag applied to all resources for identification"
  type        = string
  default     = "terraform-aws-ec2-infra"
}
