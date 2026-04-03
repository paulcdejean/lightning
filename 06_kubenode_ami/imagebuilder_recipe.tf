resource "aws_imagebuilder_component" "kubenode" {
  name     = "lightning-${tofu.workspace}-kubenode"
  data     = yamlencode(local.kubenode_imagebuilder_component)
  platform = "Linux"
  version  = "1.0.0"
}

locals {
  # Recommended by Amazon for data volumes on linux.
  container_volume_device_name = "sdf"
}

resource "aws_imagebuilder_image_recipe" "kubenode" {
  name = "lightning-${tofu.workspace}-kubenode"
  block_device_mapping {
    # Source of truth for the device name, is the base ami.
    # This will be different for fedora vs debian for example.
    device_name = data.aws_ami.fedora.root_device_name
    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }
  # Container volume.
  block_device_mapping {
    device_name = "/dev/${local.container_volume_device_name}"
    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }
  component {
    component_arn = aws_imagebuilder_component.kubenode.arn
  }
  user_data_base64 = base64encode(templatefile("${path.module}/templates/fedora_imagebuilder_userdata.bash", {
  }))
  parent_image = "ssm:${aws_ssm_parameter.base_image.name}"
  version      = "1.0.0"
  systems_manager_agent {
    # We need to do this, because we'll have these running in ipv6 only subnets where system manager doesn't work.
    uninstall_after_build = true
  }
}
