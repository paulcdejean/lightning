resource "aws_secretsmanager_secret" "cloudflared_tunnel" {
  name                    = "${tofu.workspace}/cloudflared_tunnel"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cloudflared_tunnel" {
  secret_id     = aws_secretsmanager_secret.cloudflared_tunnel.id
  secret_string = data.cloudflare_zero_trust_tunnel_cloudflared_token.lightning.token
}

resource "tls_private_key" "cloudflared_admin_ssh" {
  count     = local.workspace.enable_admin_ssh ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_secretsmanager_secret" "cloudflared_admin_ssh" {
  count                   = local.workspace.enable_admin_ssh ? 1 : 0
  name                    = "${tofu.workspace}/admin_ssh_keys/cloudflared"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cloudflared_admin_ssh" {
  count         = local.workspace.enable_admin_ssh ? 1 : 0
  secret_id     = aws_secretsmanager_secret.cloudflared_admin_ssh[0].id
  secret_string = tls_private_key.cloudflared_admin_ssh[0].private_key_openssh
}

resource "aws_key_pair" "cloudflared_admin_ssh" {
  count           = local.workspace.enable_admin_ssh ? 1 : 0
  key_name_prefix = "lightning-${tofu.workspace}-cloudflared"
  public_key      = tls_private_key.cloudflared_admin_ssh[0].public_key_openssh
  lifecycle {
    create_before_destroy = true
  }
}
