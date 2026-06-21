data "cloudflare_accounts" "account" {
  max_items = 1
}
data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = local.cf_account_id
}

locals {
  cf_account_id = data.cloudflare_accounts.account.result[0].id
  cf_permission_groups = {
    for group in data.cloudflare_account_api_token_permission_groups_list.all.result :
    group.name => group.id
    if contains(group.scopes, "com.cloudflare.api.account")
  }
  cf_perms_scope_to_ids = transpose({
    for group in data.cloudflare_account_api_token_permission_groups_list.all.result :
    group.id => group.scopes
  })
  cf_perms_ids_to_names = {
    for group in data.cloudflare_account_api_token_permission_groups_list.all.result :
    group.id => group.name
  }
  cf_perm_groups = {
    for k, v in local.cf_perms_scope_to_ids :
    k => {
      for id in v :
      local.cf_perms_ids_to_names[id] => id
    }
  }
}

resource "cloudflare_account_token" "agent" {
  account_id = local.cf_account_id
  name       = "lightning-agent-ai"

  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.api.account.${local.cf_account_id}" = "*"
    })
    # This token backs the Cloudflare terraform provider via .env:
    #   * CLOUDFLARE_API_TOKEN -> used by the read-only `tofu plan` chores
    #     across every cloudflare-using folder (this one, 02, 05, 06). Bearer auth
    #     (CLOUDFLARE_API_TOKEN) is required because the value is an API
    #     *token*, not a global API key.
    # The jail's LLM traffic no longer routes through Cloudflare (it uses
    # OpenRouter), so the former Workers AI / AI Gateway read perms are gone.
    # Read perms are granted where they exist. The Zero Trust device default
    # profile (02) and the tunnel routes / tunnel token data source (05/06) only
    # accept Write perms per the provider docs, so Write is granted for those.
    # The agent never runs `tofu apply`, so these cannot mutate infrastructure.
    #
    # The `contains(keys(...))` guard makes a wrong/missing name skip silently
    # instead of breaking the admin apply, so this broadening can never block
    # the verified env-var (CLOUDFLARE_API_TOKEN) change it ships with.
    permission_groups = [
      for name in [
        "Account API Tokens Read",
        "Cloudflare Tunnel Read",
        "Cloudflare Tunnel Write",
        "Zero Trust Write",
      ] : { id = local.cf_perm_groups["com.cloudflare.api.account"][name] }
      if contains(keys(local.cf_perm_groups["com.cloudflare.api.account"]), name)
    ]
  }]
}

# Read-only R2 token for the lightning agent. The terraform state backend is
# S3-on-R2 (profile = "cloudflare"; see any tofu.tf). R2 S3-compatible creds
# are *derived* from a Cloudflare API token, not supplied separately:
#   Access Key ID      = token id
#   Secret Access Key  = SHA-256 of token value
# Source: https://developers.cloudflare.com/r2/api/tokens/
#         #get-s3-api-credentials-from-an-api-token
# This iteration only surfaces the derived creds into .env; a future
# iteration will write the `[cloudflare]` AWS profile to ~/.aws/credentials.
resource "cloudflare_account_token" "r2" {
  account_id = local.cf_account_id
  name       = "lightning-agent-r2"

  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.api.account.${local.cf_account_id}" = "*"
    })
    permission_groups = [
      { id = local.cf_perm_groups["com.cloudflare.api.account"]["Workers R2 Storage Read"] },
    ]
  }]
}
