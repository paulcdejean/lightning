resource "aws_security_group" "cloudflared" {
  name   = "lightning-${tofu.workspace}-cloudflared"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-cloudflared"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
  security_group_id = aws_security_group.cloudflared.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_local_egress_ipv4" {
  security_group_id = aws_security_group.cloudflared.id
  cidr_ipv4         = data.aws_vpc.main.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_ipv6" {
  count             = local.workspace.enable_admin_ssh ? 1 : 0
  security_group_id = aws_security_group.cloudflared.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
