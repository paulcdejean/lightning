locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region                    = "us-east-2"
      instance_type             = "t4g.medium"
      enabled                   = false
      az                        = "us-east-2a"
      allow_insecure_global_ssh = true
    }
  }
}
