locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
    }
  }
}
