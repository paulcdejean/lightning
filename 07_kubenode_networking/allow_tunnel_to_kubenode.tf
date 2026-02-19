data "aws_security_group" "tunnel" {
  name = "lightning-${tofu.workspace}-cloudflared"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tunnel_to_kubenode" {
  count                        = local.workspace.enable_kubenode_debugging ? 1 : 0
  security_group_id            = aws_security_group.kubenode.id
  referenced_security_group_id = data.aws_security_group.tunnel.id
  ip_protocol                  = "-1"
}
