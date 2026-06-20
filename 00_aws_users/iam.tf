# Read-only IAM user for the lightning agent (runs inside the jail).
# Its access key is templated into ../.env so the AWS provider's default
# credential chain (env vars) can run `tofu plan` without admin creds.
resource "aws_iam_user" "lightning_agent" {
  name = "lightning-agent"
  path = "/lightning/"
}

resource "aws_iam_user_policy_attachment" "lightning_agent_readonly" {
  user       = aws_iam_user.lightning_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ReadOnlyAccess deliberately excludes secretsmanager:GetSecretValue, so the
# agent cannot `tofu plan` folder 05_cloudflare_tunnel (whose
# aws_secretsmanager_secret_version resources read the tunnel token / admin SSH
# key at plan time). Grant GetSecretValue on just those two secret-name
# patterns, scoped to this account + region. DescribeSecret/ListSecrets are
# already allowed by ReadOnlyAccess.
resource "aws_iam_user_policy" "lightning_agent_secrets_read" {
  name = "secretsmanager-getsecretvalue"
  user = aws_iam_user.lightning_agent.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "secretsmanager:GetSecretValue"
      Resource = [
        "arn:aws:secretsmanager:${local.workspace.region}:${data.aws_caller_identity.current.account_id}:secret:*/cloudflared_tunnel-*",
        "arn:aws:secretsmanager:${local.workspace.region}:${data.aws_caller_identity.current.account_id}:secret:*/admin_ssh_keys/cloudflared-*",
      ]
    }]
  })
}

resource "aws_iam_access_key" "lightning_agent" {
  user = aws_iam_user.lightning_agent.name
}
