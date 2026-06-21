resource "cloudflare_account_token" "admin" {
  account_id = local.cf_account_id
  name       = "lightning-admin"

  policies = [{
    effect = "allow"
    resources = jsonencode({
      "com.cloudflare.api.account.${local.cf_account_id}" = "*"
    })
    permission_groups = [
      for permission in data.cloudflare_account_api_token_permission_groups_list.all.result :
      {
        id   = permission.id
        name = permission.name
      }
      if strcontains(lower(permission.name), "write")
    ]
  }]
}

resource "aws_secretsmanager_secret" "cf_admin" {
  name = "admin/cloudflare"
}

resource "aws_secretsmanager_secret_version" "cf_admin" {
  secret_id                = aws_secretsmanager_secret.cf_admin.name
  secret_string_wo         = cloudflare_account_token.admin.value
  secret_string_wo_version = 0
}
