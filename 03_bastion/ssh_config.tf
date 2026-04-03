locals {
  private_key_local_path = pathexpand("~/.ssh/bastion.pem")
}

resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "bastion" {
  key_name_prefix = "lightning-${tofu.workspace}-bastion"
  public_key      = tls_private_key.bastion.public_key_openssh
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_sensitive_file" "bastion_ssh_private_key" {
  content         = tls_private_key.bastion.private_key_openssh
  file_permission = "0600"
  filename        = local.private_key_local_path
}

resource "local_file" "bastion_ssh_conf" {
  content = templatefile("${path.module}/templates/bastion.config", {
    ipv6_address     = aws_instance.bastion.ipv6_addresses[0]
    private_key_path = local.private_key_local_path
  })
  file_permission = "0600"
  filename        = pathexpand("~/.ssh/conf.d/bastion.config")
  lifecycle {
    enabled = local.workspace.enabled
  }
}
