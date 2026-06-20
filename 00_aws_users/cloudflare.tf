# ----------------------------------------------------------------------------
# Cloudflare AI Gateway bootstrap for the lightning agent.
#
# This folder is the home for foundational auth. We provision:
#   1. A Cloudflare AI Gateway that fronts Workers AI (GLM-5.2). The long
#      cache_ttl is the main cost lever for an agentic coding workload, where
#      the system prompt + tool schemas repeat on every turn.
#   2. A scoped Cloudflare account token the agent uses to call inference
#      through the gateway. Limited to Workers AI + AI Gateway on this account
#      only (no zone / DNS / account-settings access).
#   3. The repo-root .env file, fully managed by opentofu and injected into the
#      sandbox at runtime. .env is gitignored; the token also lives in state,
#      which is stored in the private R2 backend.
#
# Everything here is account-scoped (lives under /accounts/{id}/...), so the
# provider authenticates with an account API token via CLOUDFLARE_API_TOKEN,
# the same way 05_cloudflare_tunnel does -- no user-level (Global API Key)
# auth required. Apply this from outside the container.
# ----------------------------------------------------------------------------

data "cloudflare_accounts" "account" {
  max_items = 1
}

# Account-scoped permission group list. Hits /accounts/{id}/tokens/permission_groups
# (reachable with an account API token, unlike the user-level
# cloudflare_api_token_permission_groups_list which returns 9109). We fetch the
# full list and resolve the two IDs we need by exact name client-side, since
# server-side name filtering was returning empty results.
data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = local.cf_account_id
}

locals {
  cf_account_id = data.cloudflare_accounts.account.result[0].id

  # Account-scoped permission groups only. Cloudflare has permission groups
  # with the same display name at different scopes (e.g. "Logs Write" exists
  # at both account and zone scope), so a name-only map would hit duplicate
  # keys. Restricting to the account scope keeps names unique within the map
  # and matches the scopes of the two groups we actually need.
  pg_by_name = {
    for pg in data.cloudflare_account_api_token_permission_groups_list.all.result :
    pg.name => pg.id
    if contains(pg.scopes, "com.cloudflare.api.account")
  }
  workers_ai_read_id = local.pg_by_name["Workers AI Read"]
  ai_gateway_read_id = local.pg_by_name["AI Gateway Read"]
}

resource "cloudflare_ai_gateway" "lightning" {
  account_id                 = local.cf_account_id
  id                         = "lightning"
  cache_invalidate_on_update = true
  cache_ttl                  = 3600
  collect_logs               = true
  rate_limiting_interval     = 0
  rate_limiting_limit        = 0
  # Require the scoped token on requests routed through the gateway.
  authentication = true

  # Absorb transient upstream 429/5xx (e.g. Workers AI per-minute rate caps)
  # at the gateway so they never surface to pi. Exponential backoff: ~0.5s,
  # ~1s, ~2s across 3 attempts.
  retry_backoff      = "exponential"
  retry_delay        = 500
  retry_max_attempts = 3
}

# Account token (vs user token): minted via /accounts/{id}/tokens, so the
# account API token authenticating the provider is sufficient. No user-level
# /Global API Key needed.
resource "cloudflare_account_token" "agent" {
  account_id = local.cf_account_id
  name       = "lightning-agent-ai"

  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.api.account.${local.cf_account_id}" = "*"
    })
    permission_groups = [
      { id = local.workers_ai_read_id },
      { id = local.ai_gateway_read_id },
    ]
  }]
}

# .env is owned by opentofu. local_sensitive_file keeps the content out of
# plan output; the file is gitignored at the repo root.
resource "local_sensitive_file" "env" {
  filename        = "${path.module}/../.env"
  file_permission = "0600"
  content = templatefile("${path.module}/env.tftpl", {
    cloudflare_api_token  = cloudflare_account_token.agent.value
    cloudflare_account_id = local.cf_account_id
    cloudflare_ai_gateway = cloudflare_ai_gateway.lightning.id
  })
}
