locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      cilium_version = "1.18.6"
    }
  }
}
