resource "helm_release" "aws_cni" {
  name       = "amazon-vpc-cni"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = "1.21.1"
  set = [
    {
      name  = "init.image.overrideRepository"
      value = "ecr-public.aws.com/eks/amazon-k8s-cni-init"
    },
  ]
}
