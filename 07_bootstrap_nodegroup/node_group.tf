data "aws_eks_cluster" "main" {
  name = "lightning-${tofu.workspace}"
}

data "aws_subnets" "ipv6only_private" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-ipv6only-private-*"]
  }
}

resource "aws_eks_node_group" "bootstrap" {
  cluster_name           = data.aws_eks_cluster.main.name
  node_group_name_prefix = "bootstrap-${tofu.workspace}"
  node_role_arn          = aws_iam_role.bootstrap_nodegroup.arn
  subnet_ids             = toset(data.aws_subnets.ipv6only_private.ids)
  scaling_config {
    desired_size = local.workspace.bootstrap_nodegroup_instance_count
    max_size     = local.workspace.bootstrap_nodegroup_instance_count
    min_size     = local.workspace.bootstrap_nodegroup_instance_count
  }
  # The following comment is from the terraform provider docs:
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.bootstrap_nodegroup_default_a,
    aws_iam_role_policy_attachment.bootstrap_nodegroup_default_b,
  ]
}
