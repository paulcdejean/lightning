resource "helm_release" "aws_cni" {
  name       = "amazon-vpc-cni"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = local.workspace.version
  set = [
    {
      name  = "image.overrideRepository"
      value = "ecr-public.aws.com/eks/amazon-k8s-cni-init"
    },
    {
      name  = "image.tag"
      value = "v${local.workspace.version}"
    },
    {
      name  = "init.image.overrideRepository"
      value = "ecr-public.aws.com/eks/amazon-k8s-cni-init"
    },
    {
      name  = "init.image.tag"
      value = "v${local.workspace.version}"
    },
    {
      name  = "nodeAgent.image.overrideRepository"
      value = "ecr-public.aws.com/eks/amazon-k8s-cni-init"
    },
    {
      name  = "nodeAgent.image.tag"
      value = "v${local.workspace.version}"
    },
  ]
}
