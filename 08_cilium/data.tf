data "github_repository" "cilium" {
  full_name = "cilium/cilium"
}

data "aws_eks_cluster" "lightning" {
  name = "lightning-${tofu.workspace}"
}
