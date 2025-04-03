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

variable "cluster_config_file" {
  default = "manifest.json"
}

locals {
  cluster_config        = jsondecode(file(var.cluster_config_file))
  WORKER_COUNT          = local.cluster_config.worker_nodes.count
  CONTROL_PLANE_COUNT   = local.cluster_config.control_plane.count
  WORKER_INSTANCE_TYPE  = local.cluster_config.worker_nodes.instance_type
  CONTROL_PLANE_INSTANCE_TYPE = local.cluster_config.control_plane.instance_type
}

output "WORKER_COUNT" {
  value = local.WORKER_COUNT
}

output "CONTROL_PLANE_COUNT" {
  value = local.CONTROL_PLANE_COUNT
}

output "WORKER_INSTANCE_TYPE" {
  value = local.WORKER_INSTANCE_TYPE
}

output "CONTROL_PLANE_INSTANCE_TYPE" {
  value = local.CONTROL_PLANE_INSTANCE_TYPE
}


resource "aws_instance" "control_plane" {
  ami           = "ami-05d38da78ce859165"
  instance_type = local.CONTROL_PLANE_INSTANCE_TYPE
  count         = local.CONTROL_PLANE_COUNT
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
  instance_type = local.WORKER_INSTANCE_TYPE
  count         = local.WORKER_COUNT
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