data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

data "aws_security_group" "imagebuilder" {
  name   = "lightning-${tofu.workspace}-imagebuilder"
}
