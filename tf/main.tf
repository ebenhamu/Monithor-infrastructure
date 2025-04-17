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
  CLUSTER_NAME           = local.cluster_config.cluster_Name
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
  ami           = var.ami
  instance_type = local.CONTROL_PLANE_INSTANCE_TYPE
  count         = local.CONTROL_PLANE_COUNT
  key_name      = var.key_name
  tags = {
    Name     = "${local.CLUSTER_NAME}_control_plane"
    k8s_role = "${local.CLUSTER_NAME}_control_plane"
  }
  root_block_device {
    volume_size = 10  # Set the root disk size to 10GB
    volume_type = "gp2"  # You can specify the volume type as well, default is "gp2"
  }
}

resource "aws_instance" "worker" {
  ami           = var.ami
  instance_type = local.WORKER_INSTANCE_TYPE
  count         = local.WORKER_COUNT
  key_name      = var.key_name
  tags = {  
    Name     = "${local.CLUSTER_NAME}_worker_${count.index + 1}"
    k8s_role = "${local.CLUSTER_NAME}_worker"
  }
  root_block_device {
    volume_size = 10  # Set the root disk size to 10GB
    volume_type = "gp2"  # You can specify the volume type as well, default is "gp2"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "inventory.ini"
  content = <<EOF
[Private IP]
[control_plane]
${join("\n", [for cp in aws_instance.control_plane : "${local.CLUSTER_NAME}_control_plane=${cp.private_ip}"])}

[workers]
${join("\n", [for i, worker in aws_instance.worker : "${local.CLUSTER_NAME}_worker_${i + 1}=${worker.private_ip}"])}

[Public IP]
[control_plane]
${join("\n", [for cp in aws_instance.control_plane : "${local.CLUSTER_NAME}_control_plane_public=${cp.public_ip}"])}

[workers]
${join("\n", [for i, worker in aws_instance.worker : "${local.CLUSTER_NAME}_worker_${i + 1}_public=${worker.public_ip}"])}

EOF
}





output "public_ips" {
  value = {
    control_plane = aws_instance.control_plane.*.public_ip
    workers       = { for i, worker in aws_instance.worker : "worker_${i + 1}" => worker.public_ip }
  }
}

output "private_ips" {
  value = {
    control_plane = aws_instance.control_plane.*.private_ip
    workers       = { for i, worker in aws_instance.worker : "worker_${i + 1}" => worker.private_ip }
  }
}
