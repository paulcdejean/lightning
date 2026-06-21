resource "aws_imagebuilder_distribution_configuration" "cloudflared" {
  name = "lightning-${tofu.workspace}-cloudflared"
  distribution {
    region = data.aws_region.current.region
    ami_distribution_configuration {
      name = "lightning-${tofu.workspace}-cloudflared-{{ imagebuilder:buildDate }}"
    }
    ssm_parameter_configuration {
      parameter_name = aws_ssm_parameter.cloudflared.name
    }
  }
}
