locals {
  dualstack_public_ipv6_ranges = {
    for k, v in local.azs : k =>
    provider::toml::decode(file("${path.module}/network.toml")).ipv6["dualstack-public-${v}"]
  }
  dualstack_public_ipv6_blocks = {
    for k, v in local.dualstack_public_ipv6_ranges : k =>
    "${local.ipv6_prefix}${format("%x", local.ipv6_cidr_fourth_numeric + v)}::/64"
  }
  dualstack_public_ipv4_blocks = {
    for k, v in local.azs : k =>
    "${local.workspace.ipv4_cidr_prefix}${provider::toml::decode(file("${path.module}/network.toml")).ipv4["dualstack-public-${v}"]}"
  }
}

resource "aws_subnet" "dualstack_public" {
  for_each                                       = local.azs
  vpc_id                                         = data.aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_cidr_block                                = local.dualstack_public_ipv6_blocks[each.key]
  cidr_block                                     = local.dualstack_public_ipv4_blocks[each.key]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = true
  enable_resource_name_dns_a_record_on_launch    = true
  tags = {
    Name = "lightning-${tofu.workspace}-dualstack-public-${each.key}"
  }
}

resource "aws_route_table" "dualstack_public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-dualstack-public"
  }
}

resource "aws_route" "dualstack_public_ipv6_to_internet" {
  route_table_id              = aws_route_table.dualstack_public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.main.id
}

resource "aws_route" "dualstack_public_ipv4_to_internet" {
  route_table_id         = aws_route_table.dualstack_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "dualstack_public" {
  for_each       = aws_subnet.dualstack_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dualstack_public.id
}
