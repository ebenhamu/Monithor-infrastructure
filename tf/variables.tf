variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key name for EC2 instances"
  type        = string
}

variable "key_path" {
  description = "Path to the key file"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for EC2 instances"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for EC2 instances"
  type        = string
}

variable "CONTROL_PLANE_COUNT" {
  description = "Number of control plane instances"
  type        = number
  default     = 1
}

variable "WORKER_COUNT" {
  description = "Number of worker instances"
  type        = number
  default     = 2
}