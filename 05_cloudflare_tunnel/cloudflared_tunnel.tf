resource "cloudflare_zero_trust_tunnel_cloudflared" "lightning" {
  name       = "lightning-${tofu.workspace}"
  account_id = local.workspace.cf_account_id
  config_src = "cloudflare"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "lightning" {
  account_id = local.workspace.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lightning.id
}

data "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "default" {
  account_id = local.workspace.cf_account_id
  filter = {
    is_default = true
  }
  depends_on = [
    cloudflare_zero_trust_tunnel_cloudflared.lightning
  ]
}
