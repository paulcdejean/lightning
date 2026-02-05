data "aws_subnet" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-dualstack-private-${local.workspace.az}"]
  }
}

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

data "aws_ami" "flatcar" {
  most_recent = true
  owners      = ["075585003325"] # Flatcar current account
  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
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

resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "bastion" {
  key_name_prefix = "lightning-${tofu.workspace}-bastion"
  public_key      = tls_private_key.bastion.public_key_openssh
  lifecycle {
    create_before_destroy = true
  }
}

resource "local_sensitive_file" "bastion_ssh_private_key" {
  content         = tls_private_key.bastion.private_key_openssh
  file_permission = "0600"
  filename        = pathexpand("~/.ssh/bastion.pem")
}

resource "aws_instance" "bastion" {
  count                       = local.workspace.enabled ? 1 : 0
  ami                         = data.aws_ami.flatcar.id
  instance_type               = local.workspace.instance_type
  subnet_id                   = data.aws_subnet.bastion.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.bastion.key_name
  # user_data_base64 = base64encode(templatefile("${path.module}/templates/userdata.bash.tftpl", {
  #   public_key = trimspace(file("~/.ssh/id_ed25519.pub"))
  # }))
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    enable_resource_name_dns_a_record    = false
    hostname_type                        = "resource-name"
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
  }
  tags = {
    Name = "lightning-${tofu.workspace}-bastion"
  }
}
