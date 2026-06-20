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
# grant is made here.

data "aws_caller_identity" "current" {}

data "aws_iam_user" "lightning_agent" {
  user_name = "lightning-agent"
}

data "aws_iam_policy_document" "lightning_agent_secret_read" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:secretsmanager:${local.workspace.region}:${data.aws_caller_identity.current.account_id}:secret:${tofu.workspace}/cloudflared_tunnel-*",
      "arn:aws:secretsmanager:${local.workspace.region}:${data.aws_caller_identity.current.account_id}:secret:${tofu.workspace}/admin_ssh_keys/cloudflared-*",
    ]
  }
}

resource "aws_iam_user_policy" "lightning_agent_secret_read" {
  name   = "secretsmanager-getsecretvalue"
  user   = data.aws_iam_user.lightning_agent.user_name
  policy = data.aws_iam_policy_document.lightning_agent_secret_read.json
}
