data "aws_subnet" "ipv6_only_private" {
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

resource "aws_instance" "bastion" {
  count                       = local.workspace.enabled ? 1 : 0
  ami                         = "ami-0ba981d883d8ee606"
  instance_type               = local.workspace.instance_type
  subnet_id                   = data.aws_subnet.ipv6_only_private.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/templates/userdata.bash.tftpl", {
    public_key = trimspace(file("~/.ssh/id_ed25519.pub"))
  }))
  tags = {
    Name = "lightning-${tofu.workspace}-bastion"
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
  }
}
