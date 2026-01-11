resource "aws_imagebuilder_image_pipeline" "cloudflared" {
  name                             = "lightning-${tofu.workspace}-cloudflared"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.cloudflared.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.lightning.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.cloudflared.arn
  execution_role                   = aws_iam_role.imagebuilder_execution.arn
  logging_configuration {
    image_log_group_name    = aws_cloudwatch_log_group.image_log_group.name
    pipeline_log_group_name = aws_cloudwatch_log_group.pipeline_log_group.name
  }
  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_recipe.cloudflared
    ]
  }
  provisioner "local-exec" {
    command = "aws imagebuilder start-image-pipeline-execution --image-pipeline-arn ${self.arn}"
  }
}

resource "aws_iam_role" "imagebuilder_execution" {
  name = "lightning-${tofu.workspace}-imagebuilder-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "imagebuilder.amazonaws.com"
        }
      },
    ]
  })
}

# You can't attach this policy directly for no good reason.
# So instead we use terraform to copy paste the policy into an inline policy.
data "aws_iam_policy" "service_role_for_imagebuilder" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForImageBuilder"
}

resource "aws_iam_role_policy" "imagebuilder_defaults" {
  name   = "imagebuilder_required"
  role   = aws_iam_role.imagebuilder_execution.id
  policy = data.aws_iam_policy.service_role_for_imagebuilder.policy
}

resource "aws_iam_role_policy" "imagebuilder_ssm" {
  name = "ssm_access"
  role = aws_iam_role.imagebuilder_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DeleteParameters",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/lightning-amis/${tofu.workspace}/*"
      },
      {
        Action   = ["ssm:DescribeParameters"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
