data "aws_eks_cluster" "lightning" {
  name = "lightning-${tofu.workspace}"
}

data "aws_ssm_parameter" "kubenode" {
  name = "/lightning-amis/${tofu.workspace}/kubenode"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

data "aws_security_group" "kubenode" {
  name = "lightning-${tofu.workspace}-kubenode"
}
