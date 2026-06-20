# Grant the jail's read-only agent user (created in 00_aws_users) the ability to
# read the Secrets Manager secrets that live in *this* layer, so it can run
# `tofu plan` here. ReadOnlyAccess deliberately omits
# secretsmanager:GetSecretValue; DescribeSecret/ListSecrets are already covered
# by it, so only GetSecretValue is granted here.
#
# Layering rule: the inline policy is attached in the layer where the secrets
# exist (reaching backwards to the user from 00_aws_users), never reaching
# forward from layer 0 to a secret that does not exist yet. Both secrets this
# policy covers are declared in this same folder (see secretmanger.tf), so the
# grant is made here and the resource ARNs are referenced directly.

data "aws_iam_user" "lightning_agent" {
  user_name = "lightning-agent"
}

locals {
  # ARNs of the Secrets Manager secrets declared in this layer. The admin SSH
  # secret only exists when enable_admin_ssh is true, so it is included
  # conditionally and compact() drops it when disabled.
  agent_secret_arns = compact([
    aws_secretsmanager_secret.cloudflared_tunnel.arn,
    local.workspace.enable_admin_ssh ? aws_secretsmanager_secret.cloudflared_admin_ssh.arn : null,
  ])
}

data "aws_iam_policy_document" "lightning_agent_secret_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = local.agent_secret_arns
  }
}

resource "aws_iam_user_policy" "lightning_agent_secret_read" {
  name   = "secretsmanager-getsecretvalue"
  user   = data.aws_iam_user.lightning_agent.user_name
  policy = data.aws_iam_policy_document.lightning_agent_secret_read.json
}
