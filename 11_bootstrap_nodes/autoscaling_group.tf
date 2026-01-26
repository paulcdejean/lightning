data "aws_subnets" "kubenode" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-kubenode-small-*"]
  }
}

resource "aws_autoscaling_group" "bootstrap_nodegroup" {
  name_prefix       = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  max_size          = local.workspace.node_count
  min_size          = 0
  desired_capacity  = local.workspace.node_count
  health_check_type = "EC2"
  launch_template {
    id = aws_launch_template.bootstrap_kubenode.id
  }
  vpc_zone_identifier = toset(data.aws_subnets.kubenode.ids)
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-only"
  }
  tag {
    key                 = "Name"
    value               = "lightning-${tofu.workspace}-bootstrap-kubenode"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      aws_launch_template.bootstrap_kubenode,
    ]
    ignore_changes = [
      desired_capacity
    ]
  }
  depends_on = [
    aws_eks_access_entry.kubenode
  ]
}
