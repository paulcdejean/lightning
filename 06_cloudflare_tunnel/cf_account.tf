data "cloudflare_accounts" "account" {
  max_items = 1
}

locals {
  cf_account_id = data.cloudflare_accounts.account.result[0].id
}
