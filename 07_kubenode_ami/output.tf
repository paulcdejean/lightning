output "test_command" {
  value = "aws imagebuilder create-image --image-recipe-arn ${aws_imagebuilder_image_recipe.kubenode.arn} --infrastructure-configuration-arn ${data.aws_imagebuilder_infrastructure_configuration.lightning.arn}"
}
