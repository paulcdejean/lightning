data "aws_region" "current" {}

data "aws_iam_roles" "admin" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.region}/"
  name_regex  = "AWSReservedSSO_admin_.*"
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_subnets" "dualstack_private" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-dualstack-private-*"]
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

data "aws_security_group" "cloudflared" {
  name = "lightning-${tofu.workspace}-cloudflared"
}

data "aws_security_group" "bastion" {
  name = "lightning-${tofu.workspace}-bastion"
}
