data "cloudflare_accounts" "account" {
  max_items = 1
}

data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = local.cf_account_id
}

data "aws_ssoadmin_instances" "main" {}

data "aws_caller_identity" "current" {}
