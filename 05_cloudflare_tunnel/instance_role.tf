resource "aws_iam_instance_profile" "cloudflared" {
  name = "lightning-${tofu.workspace}-cloudflared"
  role = aws_iam_role.cloudflared.name
}

resource "aws_iam_role" "cloudflared" {
  name               = "lightning-${tofu.workspace}-cloudflared"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.cloudflared_assume_role.json
}

data "aws_iam_policy_document" "cloudflared_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudflared_secret_read" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.cloudflared_tunnel.arn
    ]
  }
}

resource "aws_iam_role_policy" "cloudflared_secret_read" {
  name   = "cloudflared_secret_read"
  role   = aws_iam_role.cloudflared.id
  policy = data.aws_iam_policy_document.cloudflared_secret_read.json
}
