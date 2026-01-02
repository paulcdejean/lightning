resource "cloudflare_zero_trust_device_default_profile" "route_ipspace_through_warp" {
  account_id = "287cae24e46a0aeed1dbc2942fc58dd7"
  service_mode_v2 = {
    mode = "warp"
  }
  tunnel_protocol = "wireguard"
  include = [
    {
      address     = "10.0.0.0/8"
      description = "Datacenter ip range"
    },
    {
      address     = aws_vpc_ipam_pool_cidr.public.cidr,
      description = "Lightning reserved ipv6 space"
    }
  ]
}
