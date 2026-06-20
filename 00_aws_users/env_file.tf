resource "local_sensitive_file" "env" {
  filename        = "${path.module}/../.env"
  file_permission = "0600"
  content = templatefile("${path.module}/templates/env.tftpl", {
    cloudflare_api_token  = cloudflare_account_token.agent.value
    cloudflare_account_id = local.cf_account_id
    cloudflare_ai_gateway = cloudflare_ai_gateway.lightning.id
  })
}
