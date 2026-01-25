resource "aws_launch_template" "bootstrap_kubenode" {
  name     = "lightning-${tofu.workspace}-bootstrap-kubenode"
  image_id = "resolve:ssm:${data.aws_ssm_parameter.kubenode.name}"
  instance_market_options {
    market_type = "spot"
  }
  instance_type          = local.workspace.instance_type
  key_name               = local.workspace.enable_admin_ssh ? aws_key_pair.bootstrap_nodegroup_admin_ssh[0].id : null
  vpc_security_group_ids = [data.aws_security_group.kubenode.id]
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
    # This stops pods from being able to assume the instance role.
    # https://docs.aws.amazon.com/eks/latest/best-practices/identity-and-access-management.html
    # Under: "Restrict access to the instance profile assigned to the worker node"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.kubenode.arn
  }
  update_default_version = true
  user_data = base64encode(templatefile("${path.module}/templates/bootstrap_kubenode_userdata.bash", {
    cluster_name = data.aws_eks_cluster.lightning.name
  }))
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    enable_resource_name_dns_a_record    = false
    hostname_type                        = "resource-name"
  }
}

