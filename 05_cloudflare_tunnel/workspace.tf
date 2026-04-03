locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket = "lightning-593941967609-us-east-2-an"
      # In AWS creds are tied to a specific account, but in cloudflare they're not.
      # In fact you can even use one provider to manage multiple accounts in cloudflare.
      # So we need to explicitly specify an account id.
      cf_account_id    = "287cae24e46a0aeed1dbc2942fc58dd7"
      min_replicas     = 0
      max_replicas     = 2
      desired_replicas = 2
      instance_type    = "t4g.small"
      enable_admin_ssh = false
    }
  }
}
