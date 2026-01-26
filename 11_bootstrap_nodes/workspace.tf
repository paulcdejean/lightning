locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      node_count       = 1
      instance_type    = "t4g.medium"
      enable_admin_ssh = true
    }
  }
}
