data "aws_security_group" "cloudflared" {
  name = "lightning-${tofu.workspace}-cloudflared"
}

resource "aws_vpc_security_group_ingress_rule" "allow_network_access_from_tunnel" {
  security_group_id            = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = data.aws_security_group.cloudflared.id
  ip_protocol                  = "-1"
}
