data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

resource "aws_security_group" "bootstrap_nodegroup" {
  name   = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
  security_group_id = aws_security_group.bootstrap_nodegroup.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_self_communication" {
  security_group_id            = aws_security_group.bootstrap_nodegroup.id
  referenced_security_group_id = aws_security_group.bootstrap_nodegroup.id
  ip_protocol                  = "-1"
}

locals {
  control_plane_security_group = data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_node_to_control_plane" {
  security_group_id            = local.control_plane_security_group
  referenced_security_group_id = aws_security_group.bootstrap_nodegroup.id
  ip_protocol                  = "-1"
}
