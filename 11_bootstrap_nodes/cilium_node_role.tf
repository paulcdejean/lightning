resource "kubernetes_cluster_role_v1" "cilium_node" {
  metadata {
    name = "cilium-node"
  }
  rule {
    api_groups = ["cilium.io"]
    resources  = ["ciliumnodes"]
    verbs      = ["get", "list", "watch", "create", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "bind_node_to_cilium_node" {
  metadata {
    name = "node-to-cilium-node"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.cilium_node.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "system:nodes"
    api_group = "rbac.authorization.k8s.io"
  }
}
