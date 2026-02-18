locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      instance_type             = "t4g.medium"
      enabled                   = true
      az                        = "us-east-2a"
      allow_insecure_global_ssh = false
    }
  }
}
