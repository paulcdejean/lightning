resource "aws_identitystore_user" "users" {
  for_each          = local.users_map
  identity_store_id = local.identity_store_id
  display_name      = "${each.value.first} ${each.value.last}"
  user_name         = each.key
  name {
    given_name  = each.value.first
    family_name = each.value.last
  }
  emails {
    primary = true
    type    = "personal"
    value   = each.value.email
  }
}
