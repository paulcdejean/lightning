resource "aws_secretsmanager_secret" "cloudflared_tunnel" {
  name                    = "${tofu.workspace}/cloudflared_tunnel"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cloudflared_tunnel" {
  secret_id     = aws_secretsmanager_secret.cloudflared_tunnel.id
  secret_string = data.cloudflare_zero_trust_tunnel_cloudflared_token.lightning.token
}

resource "tls_private_key" "cloudflared_admin_ssh" {
  algorithm = "ED25519"
  lifecycle {
    enabled = local.workspace.enable_admin_ssh
  }
}

resource "aws_secretsmanager_secret" "cloudflared_admin_ssh" {
  name                    = "${tofu.workspace}/admin_ssh_keys/cloudflared"
  recovery_window_in_days = 0
  lifecycle {
    enabled = local.workspace.enable_admin_ssh
  }
}

resource "aws_secretsmanager_secret_version" "cloudflared_admin_ssh" {
  secret_id     = aws_secretsmanager_secret.cloudflared_admin_ssh.id
  secret_string = tls_private_key.cloudflared_admin_ssh.private_key_openssh
  lifecycle {
    enabled = local.workspace.enable_admin_ssh
  }
}

resource "aws_key_pair" "cloudflared_admin_ssh" {
  key_name_prefix = "lightning-${tofu.workspace}-cloudflared"
  public_key      = tls_private_key.cloudflared_admin_ssh.public_key_openssh
  lifecycle {
    create_before_destroy = true
    enabled               = local.workspace.enable_admin_ssh
  }
}
