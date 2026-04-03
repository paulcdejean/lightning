data "aws_ami" "fedora" {
  most_recent = true
  owners      = ["125523088429"] # Fedora
  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-AmazonEC2.aarch64-43-*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ssm_parameter" "base_image" {
  name           = "/lightning-amis/${tofu.workspace}/kubenode-baseimage"
  type           = "String"
  data_type      = "aws:ec2:image"
  insecure_value = data.aws_ami.fedora.id
}
