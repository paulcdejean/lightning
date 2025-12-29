data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

resource "aws_security_group" "imagebuilder" {
  name   = "lightning-${tofu.workspace}-imagebuilder"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-imagebuilder"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
  security_group_id = aws_security_group.imagebuilder.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4" {
  security_group_id = aws_security_group.imagebuilder.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
