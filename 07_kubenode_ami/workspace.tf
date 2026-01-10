locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      az          = "us-east-2a"
    }
  }
}
