resource "helm_release" "cilium_foundation" {
  name       = "cilium-nonodes"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = local.workspace.cilium_version
  set = [
    {
      name  = "operator.enabled"
      value = false
    },
    {
      name  = "cni.iptablesRemoveAWSRules"
      value = false
    },
    {
      name  = "ipv4.enabled"
      value = false
    },
    {
      name  = "ipv6.enabled"
      value = true
    },
    {
      name = "k8sServiceHost"
      value = data.aws_eks_cluster.lightning.endpoint
    },
    {
      name = "kubeProxyReplacement"
      value = "true" # This is a string NOT a boolean.
    },
    {
      name = "kubeProxyReplacementHealthzBindAddr"
      value = "[::]:10256"
    }
  ]
}
