data "github_repository" "cilium" {
  full_name = "cilium/cilium"
}

locals {
  cilium_crd_files = toset([
    "v2/ciliumbgpadvertisements.yaml",
    "v2/ciliumbgpclusterconfigs.yaml",
    "v2/ciliumbgpnodeconfigoverrides.yaml",
    "v2/ciliumbgpnodeconfigs.yaml",
    "v2/ciliumbgppeerconfigs.yaml",
    "v2/ciliumcidrgroups.yaml",
    "v2/ciliumclusterwideenvoyconfigs.yaml",
    "v2/ciliumclusterwidenetworkpolicies.yaml",
    "v2/ciliumegressgatewaypolicies.yaml",
    "v2/ciliumendpoints.yaml",
    "v2/ciliumenvoyconfigs.yaml",
    "v2/ciliumidentities.yaml",
    "v2/ciliumloadbalancerippools.yaml",
    "v2/ciliumlocalredirectpolicies.yaml",
    "v2/ciliumnetworkpolicies.yaml",
    "v2/ciliumnodeconfigs.yaml",
    "v2/ciliumnodes.yaml",
    "v2alpha1/ciliumendpointslices.yaml",
    "v2alpha1/ciliumgatewayclassconfigs.yaml",
    "v2alpha1/ciliuml2announcementpolicies.yaml",
    "v2alpha1/ciliumpodippools.yaml",
  ])
}

data "github_repository_file" "cilium_crds" {
  for_each   = local.cilium_crd_files
  repository = data.github_repository.cilium.full_name
  branch     = local.workspace.cilium_version
  file       = "pkg/k8s/apis/cilium.io/client/crds/${each.key}"
}
