resource "kubernetes_manifest" "crds" {
  for_each = data.github_repository_file.cilium_crds
  manifest = yamldecode(each.value.content)
}
