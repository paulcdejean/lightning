data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

resource "aws_security_group" "bastion" {
  name   = "lightning-${tofu.workspace}-bastion"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_ipv6" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
