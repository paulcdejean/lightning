locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region = "us-east-2"
      min_replicas     = 0
      max_replicas     = 2
      desired_replicas = 2
      instance_type    = "t4g.small"
      enable_admin_ssh = false
    }
  }
}
