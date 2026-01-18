# The kubenode subnet is a dual stack private subnet.

locals {
  kubenode_small_ipv6_ranges = {
    for k, v in local.azs : k =>
    provider::toml::decode(file("${path.module}/../02_vpc/network.toml")).ipv6["kubenode-small-${v}"]
  }
  kubenode_small_ipv6_blocks = {
    for k, v in local.kubenode_small_ipv6_ranges : k =>
    "${local.ipv6_prefix}${format("%x", local.ipv6_cidr_fourth_numeric + v)}::/64"
  }
  kubenode_small_ipv4_blocks = {
    for k, v in local.azs : k =>
    "${local.ipv4_cidr_prefix}${provider::toml::decode(file("${path.module}/../02_vpc/network.toml")).ipv4["kubenode-small-${v}"]}"
  }
}

resource "aws_subnet" "kubenode_small" {
  for_each                                       = local.azs
  vpc_id                                         = data.aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_cidr_block                                = local.kubenode_small_ipv6_blocks[each.key]
  cidr_block                                     = local.kubenode_small_ipv4_blocks[each.key]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = false
  enable_resource_name_dns_a_record_on_launch    = true
  tags = {
    Name = "lightning-${tofu.workspace}-kubenode-small-${each.key}"
  }
}

resource "aws_route_table" "kubenode_small" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-kubenode-small"
  }
}

# HACK HACK HACK HACK HACK
# https://github.com/hashicorp/terraform-provider-aws/issues/46019
data "aws_subnets" "hack" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}-ipv6only-private-*"]
  }
}
data "aws_route_table" "hack" {
  subnet_id = data.aws_subnets.hack.ids[0]
}
data "aws_route" "hack" {
  route_table_id              = data.aws_route_table.hack.id
  destination_ipv6_cidr_block = "::/0"
}
locals {
  aws_egress_only_internet_gateway = data.aws_route.hack.egress_only_gateway_id
}

resource "aws_route" "kubenode_small_ipv6_to_internet" {
  route_table_id              = aws_route_table.kubenode_small.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = local.aws_egress_only_internet_gateway
}

resource "aws_route_table_association" "kubenode_small" {
  for_each       = aws_subnet.kubenode_small
  subnet_id      = each.value.id
  route_table_id = aws_route_table.kubenode_small.id
}
