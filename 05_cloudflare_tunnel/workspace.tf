locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      # In AWS creds are tied to a specific account, but in cloudflare they're not.
      # In fact you can even use one provider to manage multiple account in cloudflare.
      # So we need to explicitly specify an account id.
      cf_account_id    = "287cae24e46a0aeed1dbc2942fc58dd7"
      min_replicas     = 0
      max_replicas     = 2
      desired_replicas = 0
      instance_type    = "t4g.small"
      enable_admin_ssh = true
    }
  }
}
