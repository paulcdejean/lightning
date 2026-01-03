data "aws_ssm_parameter" "latest_bottlerocket" {
  name = "/aws/service/bottlerocket/aws-k8s-${data.aws_eks_cluster.main.version}/arm64/latest/image_id"
}

resource "aws_launch_template" "bootstrap_nodegroup" {
  name                   = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  image_id               = data.aws_ssm_parameter.latest_bottlerocket.insecure_value
  instance_type          = local.workspace.bootstrap_nodegroup_instance_type
  vpc_security_group_ids = [aws_security_group.bootstrap_nodegroup.id]
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
  }
  update_default_version = true
}
