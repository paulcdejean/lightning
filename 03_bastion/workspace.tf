locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region = "us-east-2"
      state_bucket              = "lightning-593941967609-us-east-2-an"
      instance_type             = "t4g.medium"
      enabled                   = false
      az                        = "us-east-2a"
      allow_insecure_global_ssh = true
    }
  }
}
