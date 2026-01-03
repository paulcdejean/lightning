resource "aws_identitystore_group" "admin" {
  display_name      = "admin"
  description       = "admin"
  identity_store_id = local.identity_store_id
}

resource "aws_ssoadmin_account_assignment" "admin" {
  instance_arn       = local.sso_instance_id
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admin.group_id
  principal_type     = "GROUP"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "admin"
  description      = "admin"
  instance_arn     = local.sso_instance_id
  session_duration = "PT12H" # A full working day
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.sso_instance_id
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}
