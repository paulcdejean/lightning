locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket = "lightning-593941967609-us-east-2-an
      kube_version = "1.34"
    }
  }
}
