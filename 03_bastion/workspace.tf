locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      instance_type = "t4g.small"
      enabled       = false
      az            = "us-east-2a"
    }
  }
}
