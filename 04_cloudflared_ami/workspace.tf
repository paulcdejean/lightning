locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region      = "us-east-2"
      az          = "us-east-2a"
      logs_bucket = "pauldejean-logs"
    }
  }
}
