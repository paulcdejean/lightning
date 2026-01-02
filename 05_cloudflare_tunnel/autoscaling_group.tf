data "aws_subnets" "ipv6_only_private" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-dualstack-private-*"]
  }
}

resource "aws_autoscaling_group" "cloudflared" {
  name_prefix       = "lightning-${tofu.workspace}-cloudflared"
  max_size          = local.workspace.max_replicas
  min_size          = local.workspace.min_replicas
  desired_capacity  = local.workspace.desired_replicas
  health_check_type = "EC2"
  launch_template {
    id = aws_launch_template.cloudflared.id
  }
  vpc_zone_identifier = toset(data.aws_subnets.ipv6_only_private.ids)
  tag {
    key                 = "Name"
    value               = "lightning-${tofu.workspace}-cloudflared"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      aws_launch_template.cloudflared,
    ]
  }
}
