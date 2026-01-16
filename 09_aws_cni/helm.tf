resource "helm_release" "aws_cni" {
  name       = "amazon-vpc-cni"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = local.workspace.version
  set = [
    # Image overrides for dualstack endpoints.
    {
      name  = "image.overrideRepository"
      value = "ecr-public.aws.com/eks/amazon-k8s-cni"
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
      value = "ecr-public.aws.com/eks/aws-network-policy-agent"
    },
    {
      name  = "nodeAgent.image.tag"
      value = "v${local.workspace.version}"
    },
    # Disable ipv4, enable ipv6.
    {
      name  = "init.env.ENABLE_IPv6"
      value = "true"
    },
    {
      name  = "nodeAgent.enableIpv6"
      value = "true"
    },
    {
      name  = "env.ENABLE_IPv6"
      value = "true"
    },
    {
      name  = "env.ENABLE_IPv4"
      value = "false"
    },
  ]
}
