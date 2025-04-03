terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  instance_type = "t3.medium"
}

resource "aws_instance" "control_plane" {
  ami           = "ami-05d38da78ce859165"
  instance_type = local.instance_type
  count         = var.CONTROL_PLANE_COUNT
  key_name      = "monithor"
  tags = {
    Name     = "monithor_control_plane"
    k8s_role = "monithor_control_plane"
  }
    root_block_device {
    volume_size = 10  # Set the root disk size to 10GB
    volume_type = "gp2"  # You can specify the volume type as well, default is "gp2"
  }
}

resource "aws_instance" "worker" {
  ami           = "ami-05d38da78ce859165"
  instance_type = local.instance_type
  count         = var.WORKER_COUNT
  key_name      = "monithor"

  tags = {  
    Name     = "monithor_worker_${count.index + 1}"
    k8s_role = "monithor_worker"
  }
    root_block_device {
    volume_size = 10  # Set the root disk size to 10GB
    volume_type = "gp2"  # You can specify the volume type as well, default is "gp2"
  }
}

output "public_ips" {
  value = {
    control_pane = aws_instance.control_plane.*.public_ip
    workers       = { for i, worker in aws_instance.worker : "worker_${i + 1}" => worker.public_ip }
    
  }
}

output "private_ips" {
  value = {
    control_pane = aws_instance.control_plane.*.private_ip
    workers       = { for i, worker in aws_instance.worker : "worker_${i + 1}" => worker.private_ip }
  }
}