resource "aws_ssm_parameter" "cloudflared" {
  name      = "lightning-${tofu.workspace}-cloudflared"
  type      = "String"
  data_type = "aws:ec2:image"
  # We need to set this to an actual AMI or else it will freak out.
  insecure_value = data.aws_ami.fedora.id
  lifecycle {
    ignore_changes = [
      insecure_value
    ]
  }
}
