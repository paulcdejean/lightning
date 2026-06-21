resource "aws_iam_user" "lightning_agent" {
  name = "lightning-agent"
  path = "/lightning/"
}

resource "aws_iam_user_policy_attachment" "lightning_agent_readonly" {
  user       = aws_iam_user.lightning_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "lightning_agent" {
  user = aws_iam_user.lightning_agent.name
}


data "aws_iam_policy_document" "agent_secrets_read" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      [
        "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:agent/*",
        "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:lightning/unstable/*",
      ]
    ]
  }
}

resource "aws_iam_user_policy" "agent_secrets_read" {
  name   = "get-agent-secrets"
  user   = aws_iam_user.lightning_agent.name
  policy = data.aws_iam_policy_document.agent_secrets_read.json
}
