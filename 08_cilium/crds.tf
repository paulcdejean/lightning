data "github_rest_api" "endpoint_versions" {
  endpoint = "repos/cilium/cilium/contents/pkg/k8s/apis/cilium.io/client/crds?ref=${local.workspace.cilium_version}"
}

locals {
  endpoint_versions = toset([
    for endpoint_version in jsondecode(data.github_rest_api.endpoint_versions.body) :
    endpoint_version.path
  ])
}

data "github_rest_api" "crds" {
  for_each = local.endpoint_versions
  endpoint = "repos/cilium/cilium/contents/${each.key}?ref=${local.workspace.cilium_version}"
}

locals {
  crd_paths = toset(flatten([
    for endpoint_version in local.endpoint_versions :
    [
      for crd in jsondecode(data.github_rest_api.crds[endpoint_version].body) : crd.path
      if endswith(crd.path, ".yaml")
    ]
  ]))
}

data "github_repository_file" "cilium_crds" {
  for_each   = local.crd_paths
  repository = data.github_repository.cilium.full_name
  branch     = local.workspace.cilium_version
  file       = each.key
}

resource "kubernetes_manifest" "crds" {
  for_each = data.github_repository_file.cilium_crds
  manifest = yamldecode(each.value.content)
}
