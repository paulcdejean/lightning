resource "aws_imagebuilder_lifecycle_policy" "kubenode" {
  name           = "lightning-${tofu.workspace}-kubenode"
  execution_role = aws_iam_role.imagebuilder_execution.arn
  resource_type  = "AMI_IMAGE"
  policy_detail {
    action {
      type = "DELETE"
    }
    filter {
      type            = "AGE"
      value           = 1
      retain_at_least = 2
      unit            = "DAYS"
    }
  }
  depends_on = [
    aws_iam_role_policy.imagebuilder_defaults,
    aws_iam_role_policy.imagebuilder_ssm
  ]
}
