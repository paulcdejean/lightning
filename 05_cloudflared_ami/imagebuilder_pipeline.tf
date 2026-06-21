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
  image_tests_configuration {
    image_tests_enabled = false
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
