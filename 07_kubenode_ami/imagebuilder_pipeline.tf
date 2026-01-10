resource "aws_imagebuilder_image_pipeline" "kubenode" {
  name                             = "lightning-${tofu.workspace}-kubenode"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.kubenode.arn
  infrastructure_configuration_arn = data.aws_imagebuilder_infrastructure_configuration.lightning.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.kubenode.arn
  execution_role                   = data.aws_iam_role.imagebuilder_execution.arn
  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_recipe.kubenode
    ]
  }
}

data "aws_iam_role" "imagebuilder_execution" {
  name = "lightning-${tofu.workspace}-imagebuilder-execution"
}
