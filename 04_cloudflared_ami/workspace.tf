locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket = "lightning-593941967609-us-east-2-an"
      az           = "us-east-2a"
      logs_bucket  = "pauldejean-logs"
    }
  }
}
