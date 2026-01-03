locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      bootstrap_nodegroup_instance_type  = "t4g.large"
      bootstrap_nodegroup_instance_count = 3

    }
  }
}
