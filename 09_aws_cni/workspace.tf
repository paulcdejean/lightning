locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      version = "1.21.1"
    }
  }
}
