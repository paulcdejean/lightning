data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

data "aws_eks_cluster" "lightning" {
  name = "lightning-${tofu.workspace}"
}
