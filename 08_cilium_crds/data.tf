data "aws_eks_cluster" "lightning" {
  name = "lightning-${tofu.workspace}"
}
