locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region         = "us-east-2"
      cilium_version = "1.18.6"
    }
  }
}
