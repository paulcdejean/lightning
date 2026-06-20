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
      { id = local.cf_permission_groups["Workers AI Read"] },
      { id = local.cf_permission_groups["AI Gateway Read"] },
    ]
  }]
}
