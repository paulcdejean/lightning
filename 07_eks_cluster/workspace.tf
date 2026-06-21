locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      kube_version              = "1.36"
      region                    = "us-east-2"
      enable_kubenode_debugging = true
    }
  }
}
