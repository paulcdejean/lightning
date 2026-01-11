data "aws_subnets" "ipv6only_private" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-ipv6only-private-*"]
  }
}

locals {
  asg_size = length(data.aws_subnets.ipv6only_private.ids) * local.workspace.nodes_per_az
}

resource "aws_autoscaling_group" "bootstrap_nodegroup" {
  name_prefix       = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  max_size          = local.asg_size
  min_size          = 0
  desired_capacity  = local.asg_size
  health_check_type = "EC2"
  launch_template {
    id = aws_launch_template.bootstrap_kubenode.id
  }
  vpc_zone_identifier = toset(data.aws_subnets.ipv6only_private.ids)
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
}
