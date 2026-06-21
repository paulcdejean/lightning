resource "null_resource" "trigger_update" {
  triggers = {
    base_image_ami = aws_ssm_parameter.base_image.insecure_value
  }
  provisioner "local-exec" {
    command = "aws imagebuilder start-image-pipeline-execution --image-pipeline-arn ${aws_imagebuilder_image_pipeline.cloudflared.arn}"
  }
  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_pipeline.cloudflared,
      aws_imagebuilder_image_recipe.cloudflared
    ]
  }
}
