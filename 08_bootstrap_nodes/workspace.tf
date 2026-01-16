locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      nodes_per_az     = 1
      instance_type    = "t4g.medium"
      enable_admin_ssh = true
    }
  }
}
