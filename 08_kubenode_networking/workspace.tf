locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket = "lightning-593941967609-us-east-2-an"
      # Enable connecting directly to nodes and pods through the tunnel, for troubleshooting.
      enable_kubenode_debugging = true
    }
  }
}
