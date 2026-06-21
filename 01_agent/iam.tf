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

resource "aws_iam_access_key" "lightning_agent" {
  user = aws_iam_user.lightning_agent.name
}
