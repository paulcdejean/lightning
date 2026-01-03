data "aws_eks_cluster" "main" {
  name = "lightning-${tofu.workspace}"
}

# Node groups need an ipv4 address sadly.
data "aws_subnets" "dualstack_private" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-dualstack-private-*"]
  }
}

resource "aws_eks_node_group" "bootstrap" {
  cluster_name           = data.aws_eks_cluster.main.name
  node_group_name_prefix = "bootstrap-${tofu.workspace}"
  node_role_arn          = aws_iam_role.bootstrap_nodegroup.arn
  subnet_ids             = toset(data.aws_subnets.dualstack_private.ids)
  capacity_type          = "SPOT"
  scaling_config {
    desired_size = local.workspace.bootstrap_nodegroup_instance_count
    max_size     = local.workspace.bootstrap_nodegroup_instance_count
    min_size     = local.workspace.bootstrap_nodegroup_instance_count
  }
  launch_template {
    id      = aws_launch_template.bootstrap_nodegroup.id
    version = aws_launch_template.bootstrap_nodegroup.latest_version
  }
  # The following comment is from the terraform provider docs:
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.bootstrap_nodegroup_default_a,
    aws_iam_role_policy_attachment.bootstrap_nodegroup_default_b,
  ]
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      aws_launch_template.bootstrap_nodegroup,
    ]
  }
}
