resource "tls_private_key" "bootstrap_nodegroup_admin_ssh" {
  count     = local.workspace.enable_admin_ssh ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_secretsmanager_secret" "bootstrap_nodegroup_admin_ssh" {
  count                   = local.workspace.enable_admin_ssh ? 1 : 0
  name                    = "${tofu.workspace}/admin_ssh_keys/bootstrap_nodegroup"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_nodegroup_admin_ssh" {
  count         = local.workspace.enable_admin_ssh ? 1 : 0
  secret_id     = aws_secretsmanager_secret.bootstrap_nodegroup_admin_ssh[0].id
  secret_string = tls_private_key.bootstrap_nodegroup_admin_ssh[0].private_key_openssh
}

resource "aws_key_pair" "bootstrap_nodegroup_admin_ssh" {
  count           = local.workspace.enable_admin_ssh ? 1 : 0
  key_name_prefix = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  public_key      = tls_private_key.bootstrap_nodegroup_admin_ssh[0].public_key_openssh
  lifecycle {
    create_before_destroy = true
  }
}
