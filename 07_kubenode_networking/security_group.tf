resource "aws_security_group" "kubenode" {
  name   = "lightning-${tofu.workspace}-kubenode"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-kubenode"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
  security_group_id = aws_security_group.kubenode.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv4" {
  security_group_id = aws_security_group.kubenode.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# As per the kubernetes networking model, all pods need to be able to communicate with each other.
resource "aws_vpc_security_group_ingress_rule" "allow_self_ingress" {
  security_group_id            = aws_security_group.kubenode.id
  referenced_security_group_id = aws_security_group.kubenode.id
  ip_protocol                  = "-1"
}

data "aws_security_group" "control_plane" {
  id = data.aws_eks_cluster.lightning.vpc_config[0].cluster_security_group_id
}

# As per the kubernetes networking model, the nodes and control plane need to be able to communicate.
resource "aws_vpc_security_group_ingress_rule" "allow_kubenode_to_control_plane" {
  security_group_id            = data.aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.kubenode.id
  ip_protocol                  = "-1"
}

# As per the kubernetes networking model, the nodes and control plane need to be able to communicate.
resource "aws_vpc_security_group_ingress_rule" "allow_control_plane_to_kubenode" {
  security_group_id            = aws_security_group.kubenode.id
  referenced_security_group_id = data.aws_security_group.control_plane.id
  ip_protocol                  = "-1"
}
