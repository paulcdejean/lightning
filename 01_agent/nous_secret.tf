# Nous Portal API key for the jail's Hermes Agent. The agent's LLM traffic
# routes through the Nous Portal (OpenAI-compatible inference API) rather than
# Cloudflare Workers AI, so the jail needs a `sk-nous-...` key surfaced into
# .env as NOUS_API_KEY (read by ~/.hermes/config.yaml's custom provider).
#
# As with github_token, the value is *not* managed by terraform: the admin
# populates it out-of-band with
#   aws secretsmanager put-secret-value \
#     --secret-id <workspace>/nous_portal_api_key --secret-string 'sk-nous-...'
# after this secret exists. The data source below reads AWSCURRENT and the
# env_file.tf templatefile injects it as NOUS_API_KEY.
#
# This grants the lightning-agent IAM user (iam.tf, same layer)
# secretsmanager:GetSecretValue on it, mirroring the github_token grant.

resource "aws_secretsmanager_secret" "nous_portal_api_key" {
  name                    = "agent/nous_portal_api_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "nous_portal_api_key" {
  secret_id                = aws_secretsmanager_secret.nous_portal_api_key.id
  secret_string_wo         = "not_the_key"
  secret_string_wo_version = 0
}

data "aws_secretsmanager_secret_version" "nous_portal_api_key" {
  secret_id = aws_secretsmanager_secret_version.nous_portal_api_key.secret_id
}
