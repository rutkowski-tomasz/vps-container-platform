terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

locals {
  common_labels = {
    "managed_by" = "terraform"
  }
}

variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

output "ip" {
  value = hcloud_server.server_test.ipv4_address
}

output "deploy_key" {
  value = tls_private_key.deploy.private_key_openssh
  sensitive = true
}

output "access_key" {
  value = tls_private_key.access.private_key_openssh
  sensitive = true
}
