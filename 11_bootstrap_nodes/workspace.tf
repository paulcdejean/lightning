locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket     = "lightning-593941967609-us-east-2-an
      node_count       = 1
      instance_type    = "t4g.medium"
      enable_admin_ssh = true
    }
  }
}
