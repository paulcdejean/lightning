locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    global = {
      state_bucket          = "lightning-593941967609-us-east-2-an
      cloudflare_account_id = "287cae24e46a0aeed1dbc2942fc58dd7"
    }
  }
}
