locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    global = {
      cloudflare_account_id = "287cae24e46a0aeed1dbc2942fc58dd7"
    }
  }
}
