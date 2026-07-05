resource "aws_secretsmanager_secret" "moltbook_api_key" {
  name                    = "agent/moltbook_api_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "moltbook_api_key" {
  secret_id                = aws_secretsmanager_secret.moltbook_api_key.id
  secret_string_wo         = "not_the_key"
  secret_string_wo_version = 0
}

data "aws_secretsmanager_secret_version" "moltbook_api_key" {
  secret_id = aws_secretsmanager_secret_version.moltbook_api_key.secret_id
}
