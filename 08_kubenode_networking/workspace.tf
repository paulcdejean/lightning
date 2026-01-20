locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      # Enable connecting directly to nodes and pods through the tunnel, for troubleshooting.
      enable_kubenode_debugging = true
    }
  }
}
