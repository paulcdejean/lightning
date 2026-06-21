resource "aws_cloudwatch_log_group" "image_log_group" {
  name              = "/aws/imagebuilder/lightning-${tofu.workspace}-cloudflared"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "pipeline_log_group" {
  name              = "/aws/imagebuilder/pipeline/lightning-${tofu.workspace}-cloudflared"
  retention_in_days = 30
}
