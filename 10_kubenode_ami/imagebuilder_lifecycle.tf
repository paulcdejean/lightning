resource "aws_imagebuilder_lifecycle_policy" "kubenode" {
  name           = "lightning-${tofu.workspace}-kubenode"
  execution_role = data.aws_iam_role.imagebuilder_execution.arn
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
  resource_selection {
    recipe {
      name             = aws_imagebuilder_image_recipe.kubenode.name
      semantic_version = aws_imagebuilder_image_recipe.kubenode.version
    }
  }
}
