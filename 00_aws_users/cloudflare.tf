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

resource "cloudflare_ai_gateway" "lightning" {
  account_id                 = local.cf_account_id
  id                         = "lightning"
  cache_invalidate_on_update = true
  cache_ttl                  = 3600
  collect_logs               = true
  rate_limiting_interval     = 0
  rate_limiting_limit        = 0
  authentication             = true
  retry_backoff              = "exponential"
  retry_delay                = 500
  retry_max_attempts         = 3
  logpush                    = false
  log_management_strategy    = "DELETE_OLDEST"
  log_management             = 100000
  zdr                        = false
}

resource "cloudflare_account_token" "agent" {
  account_id = local.cf_account_id
  name       = "lightning-agent-ai"

  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.api.account.${local.cf_account_id}" = "*"
    })
    permission_groups = [
      { id = local.cf_perm_groups["com.cloudflare.api.account"]["Workers AI Read"] },
      { id = local.cf_perm_groups["com.cloudflare.api.account"]["AI Gateway Read"] },
    ]
  }]
}
