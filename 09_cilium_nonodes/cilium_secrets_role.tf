# https://github.com/cilium/cilium/issues/44053

resource "kubernetes_role_v1" "hack" {
  metadata {
    name      = "cilium-tlsinterception-secrets"
    namespace = "cilium-secrets"
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}
