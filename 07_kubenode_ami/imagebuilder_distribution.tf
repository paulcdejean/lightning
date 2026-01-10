resource "aws_imagebuilder_distribution_configuration" "kubenode" {
  name = "lightning-${tofu.workspace}-kubenode"
  distribution {
    region = data.aws_region.current.region
    ami_distribution_configuration {
      name = "lightning-${tofu.workspace}-kubenode-{{ imagebuilder:buildDate }}"
    }
    ssm_parameter_configuration {
      parameter_name = aws_ssm_parameter.kubenode.name
    }
  }
}
