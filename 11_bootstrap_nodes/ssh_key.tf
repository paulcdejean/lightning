resource "tls_private_key" "bootstrap_nodegroup_admin_ssh" {
  count     = local.workspace.enable_admin_ssh ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "bootstrap_nodegroup_admin_ssh" {
  count           = local.workspace.enable_admin_ssh ? 1 : 0
  key_name_prefix = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  public_key      = tls_private_key.bootstrap_nodegroup_admin_ssh[0].public_key_openssh
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_sensitive_file" "bootstrap_admin_ssh_private_key" {
  count           = local.workspace.enable_admin_ssh ? 1 : 0
  content         = tls_private_key.bootstrap_nodegroup_admin_ssh[0].private_key_openssh
  file_permission = "0600"
  filename        = pathexpand("~/.ssh/bootstrap_nodegroup.pem")
}
