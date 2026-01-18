resource "aws_security_group" "kubenode" {
  name   = "lightning-${tofu.workspace}-kubenode"
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-kubenode"
  }
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ipv6" {
#   security_group_id = aws_security_group.bootstrap_kubenode.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1"
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_ipv6" {
#   count             = local.workspace.enable_admin_ssh ? 1 : 0
#   security_group_id = aws_security_group.bootstrap_kubenode.id
#   cidr_ipv6         = "::/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }

# data "aws_security_group" "control_plane" {
#   id = data.aws_eks_cluster.lightning.vpc_config[0].cluster_security_group_id
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_bootstrap_kubenode_to_control_plane" {
#   security_group_id            = data.aws_security_group.control_plane.id
#   referenced_security_group_id = aws_security_group.bootstrap_kubenode.id
#   ip_protocol                  = "-1"
# }
