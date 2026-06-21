locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  sso_instance_id   = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  users_map         = provider::toml::decode(file("${path.module}/users.toml"))
  cf_account_id     = "287cae24e46a0aeed1dbc2942fc58dd7"
}
