locals {
  imagebuilder_logs_prefix = "lightning-${tofu.workspace}-imagebuilder"
}

# Imagebuilder infrastructure takes only a single subnet, not a group of them.
data "aws_subnet" "dualstack_public" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-dualstack-public-${local.workspace.az}"]
  }
}

data "aws_imagebuilder_infrastructure_configuration" "lightning" {
  arn = "arn:aws:imagebuilder:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:infrastructure-configuration/lightning-${tofu.workspace}"
}
