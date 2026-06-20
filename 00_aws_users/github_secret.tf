# GitHub read-only PAT for the jail's lightning-agent, used by the `gh` CLI
# (installed in the jail per AGENTS.md) to look up latest software releases
# during chores. The token value is *not* managed by terraform: the admin
# populates it out-of-band with
#   aws secretsmanager put-secret-value \
#     --secret-id <name> --secret-string '<PAT>'
# after this secret exists. A later iteration will add a
# data.aws_secretsmanager_secret_version that reads AWSCURRENT and templates it
# into ../.env as GH_TOKEN.
#
# This iteration only creates the (empty) secret container and grants the
# lightning-agent IAM user (created in iam.tf in this same layer)
# secretsmanager:GetSecretValue on it. ReadOnlyAccess already covers
# DescribeSecret/ListSecrets, so only GetSecretValue is added. The grant is
# attached directly to the user resource (no data source needed) because both
# the user and the secret live in this layer.

resource "aws_secretsmanager_secret" "github_token" {
  name                    = "${tofu.workspace}/github_token"
  recovery_window_in_days = 0
}

data "aws_iam_policy_document" "lightning_agent_github_secret_read" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.github_token.arn
    ]
  }
}

resource "aws_iam_user_policy" "lightning_agent_github_secret_read" {
  name   = "github-token-getsecretvalue"
  user   = aws_iam_user.lightning_agent.name
  policy = data.aws_iam_policy_document.lightning_agent_github_secret_read.json
}
