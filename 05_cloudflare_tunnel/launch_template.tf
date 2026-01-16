data "aws_ssm_parameter" "cloudflared" {
  name = "/lightning-amis/${tofu.workspace}/cloudflared"
}


resource "aws_launch_template" "cloudflared" {
  name     = "lightning-${tofu.workspace}-cloudflared"
  image_id = "resolve:ssm:${data.aws_ssm_parameter.cloudflared.name}"
  instance_market_options {
    market_type = "spot"
  }
  instance_type          = local.workspace.instance_type
  key_name               = local.workspace.enable_admin_ssh ? aws_key_pair.cloudflared_admin_ssh[0].id : null
  vpc_security_group_ids = [aws_security_group.cloudflared.id]
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.cloudflared.arn
  }
  update_default_version = true
  user_data = base64encode(templatefile("${path.module}/templates/cloudflared_userdata.bash", {
    tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lightning.id
    secret_id = aws_secretsmanager_secret.cloudflared_tunnel.name
  }))
}
