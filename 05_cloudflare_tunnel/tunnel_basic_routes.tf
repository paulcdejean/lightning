resource "cloudflare_zero_trust_tunnel_cloudflared_route" "vpc_ipv6" {
  account_id         = local.workspace.cf_account_id
  network            = data.aws_vpc.main.ipv6_cidr_block
  tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared.lightning.id
  comment            = "lightning-${tofu.workspace} vpc"
  virtual_network_id = data.cloudflare_zero_trust_tunnel_cloudflared_virtual_network.default.id
}
