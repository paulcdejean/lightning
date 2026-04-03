locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket   = "lightning-593941967609-us-east-2-an
      cilium_version = "1.18.6"
    }
  }
}
