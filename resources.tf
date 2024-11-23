resource "hcloud_server" "server_test" {
  name        = "vps"
  image       = "docker-ce"
  server_type = "cax11"
  location    = "nbg1"
  firewall_ids = [hcloud_firewall.server_firewall.id]
  labels       = local.common_labels
  user_data   = <<EOT
#cloud-config

package_update: true
package_upgrade: true

packages:
  - ufw

users:
  - name: access
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${tls_private_key.access.public_key_openssh}
    lock_passwd: true

  - name: deploy
    groups: docker
    shell: /bin/bash
    ssh_authorized_keys:
      - ${tls_private_key.deploy.public_key_openssh}
    lock_passwd: true

runcmd:
  - sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  - sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  - systemctl restart ssh
  - ufw allow OpenSSH
  - ufw --force enable
  - docker swarm init

final_message: "Cloud-init setup completed, system ready"
EOT

  public_net {
    ipv4_enabled = true
  }
}

resource "tls_private_key" "access" {
  algorithm = "ED25519"
}

resource "tls_private_key" "deploy" {
  algorithm = "ED25519"
}

locals {
  inbound_rules = [
    {
      port       = "22"
      protocol   = "tcp"
    },
    {
      port       = "80"
      protocol   = "tcp"
    },
    {
      port       = "443"
      protocol   = "tcp"
    }
  ]
}

resource "hcloud_firewall" "server_firewall" {
  name   = "vps-firewall"
  labels = local.common_labels

  dynamic "rule" {
    for_each = local.inbound_rules
    content {
      direction  = "in"
      protocol   = rule.value.protocol
      port       = rule.value.port
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }
}
