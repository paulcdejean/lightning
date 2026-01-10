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

resource "aws_imagebuilder_component" "cloudflared" {
  name     = "lightning-${tofu.workspace}-cloudflared"
  data     = yamlencode(local.cloudflared_imagebuilder_component)
  platform = "Linux"
  version  = "1.0.0"
}

resource "aws_imagebuilder_image_recipe" "cloudflared" {
  name = "lightning-${tofu.workspace}-cloudflared"
  block_device_mapping {
    # Source of truth for the device name, is the base ami.
    # This will be different for fedora vs debian for example.
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }
  component {
    component_arn = aws_imagebuilder_component.cloudflared.arn
  }
  user_data_base64 = base64encode(templatefile("${path.module}/templates/fedora_imagebuilder_userdata.bash.tftpl", {
  }))
  parent_image = data.aws_ami.fedora.id
  version      = "1.0.0"
  systems_manager_agent {
    # We need to do this, because we'll have these running in ipv6 only subnets where system manager doesn't work.
    uninstall_after_build = true
  }
}
