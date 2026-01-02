data "aws_security_group" "bastion" {
  name = "lightning-${tofu.workspace}-bastion"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_from_tunnel" {
  security_group_id            = data.aws_security_group.bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  referenced_security_group_id = aws_security_group.cloudflared.id
}
