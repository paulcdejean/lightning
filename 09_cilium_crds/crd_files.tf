data "github_repository" "cilium" {
  full_name = "cilium/cilium"
}

locals {
  cilium_crd_files = toset([
    "ciliumbgpadvertisements.yaml",
    "ciliumbgpclusterconfigs.yaml",
    "ciliumbgpnodeconfigoverrides.yaml",
    "ciliumbgpnodeconfigs.yaml",
    "ciliumbgppeerconfigs.yaml",
    "ciliumcidrgroups.yaml",
    "ciliumclusterwideenvoyconfigs.yaml",
    "ciliumclusterwidenetworkpolicies.yaml",
    "ciliumegressgatewaypolicies.yaml",
    "ciliumendpoints.yaml",
    "ciliumenvoyconfigs.yaml",
    "ciliumidentities.yaml",
    "ciliumloadbalancerippools.yaml",
    "ciliumlocalredirectpolicies.yaml",
    "ciliumnetworkpolicies.yaml",
    "ciliumnodeconfigs.yaml",
    "ciliumnodes.yaml",
  ])
}

data "github_repository_file" "cilium_crds" {
  for_each   = local.cilium_crd_files
  repository = data.github_repository.cilium.full_name
  branch     = local.workspace.cilium_version
  file       = "pkg/k8s/apis/cilium.io/client/crds/v2/${each.key}"
}
