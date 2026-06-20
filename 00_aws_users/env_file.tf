resource "local_sensitive_file" "env" {
  filename        = "${path.module}/../.env"
  file_permission = "0600"
  content = templatefile("${path.module}/templates/env.tftpl", {
    cloudflare_api_token  = cloudflare_account_token.agent.value
    cloudflare_account_id = local.cf_account_id
    cloudflare_ai_gateway = cloudflare_ai_gateway.lightning.id
    aws_access_key_id     = aws_iam_access_key.lightning_agent.id
    aws_secret_access_key = aws_iam_access_key.lightning_agent.secret
    r2_access_key_id      = cloudflare_account_token.r2.id
    r2_secret_access_key  = sha256(cloudflare_account_token.r2.value)
    r2_endpoint           = "https://${local.cf_account_id}.r2.cloudflarestorage.com"
  })
}
