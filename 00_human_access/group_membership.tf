# TODO, change this at bigger team sizes.
resource "aws_identitystore_group_membership" "everyone_admin" {
  for_each          = aws_identitystore_user.users
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.admin.group_id
  member_id         = each.value.user_id
}
