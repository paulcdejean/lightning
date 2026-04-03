locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket              = "lightning-593941967609-us-east-2-an
      instance_type             = "t4g.medium"
      enabled                   = true
      az                        = "us-east-2a"
      allow_insecure_global_ssh = false
    }
  }
}
