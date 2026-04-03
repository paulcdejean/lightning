locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      kube_version = "1.34"
    }
  }
}
