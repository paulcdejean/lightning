locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    global = {
      region = "us-east-2"
    }
  }
}
