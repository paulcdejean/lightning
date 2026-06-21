resource "aws_secretsmanager_secret" "openrouter_api_key" {
  name                    = "agent/openrouter_api_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "openrouter_api_key" {
  secret_id                = aws_secretsmanager_secret.openrouter_api_key.id
  secret_string_wo         = "not_the_key"
  secret_string_wo_version = 0
}

data "aws_secretsmanager_secret_version" "openrouter_api_key" {
  secret_id = aws_secretsmanager_secret_version.openrouter_api_key.secret_id
}
