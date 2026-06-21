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

resource "aws_imagebuilder_infrastructure_configuration" "lightning" {
  name                          = "lightning-${tofu.workspace}"
  instance_profile_name         = aws_iam_instance_profile.imagebuilder.name
  instance_types                = ["t4g.small"]
  security_group_ids            = [aws_security_group.imagebuilder.id]
  subnet_id                     = data.aws_subnet.dualstack_public.id
  terminate_instance_on_failure = true
  logging {
    s3_logs {
      s3_bucket_name = local.workspace.logs_bucket
      s3_key_prefix  = local.imagebuilder_logs_prefix
    }
  }
}
