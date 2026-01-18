# This subnet is not private because it has private IP addresses.
# It's private because it routes internet traffic through an egress only gateway.

locals {
  ipv6only_private_ipv6_ranges = {
    for k, v in local.azs : k =>
    provider::toml::decode(file("${path.module}/network.toml")).ipv6["ipv6only-private-${v}"]
  }
  ipv6only_private_ipv6_blocks = {
    for k, v in local.ipv6only_private_ipv6_ranges : k =>
    "${local.ipv6_prefix}${format("%x", local.ipv6_cidr_fourth_numeric + v)}::/64"
  }
}

resource "aws_subnet" "ipv6_only_private" {
  for_each                                       = local.ipv6only_private_ipv6_blocks
  vpc_id                                         = data.aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_native                                    = true
  ipv6_cidr_block                                = each.value
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  tags = {
    Name = "lightning-${tofu.workspace}-ipv6only-private-${each.key}"
  }
}

resource "aws_route_table" "ipv6_only_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-ipv6only-private"
  }
}

resource "aws_route" "ipv6_only_private_to_internet" {
  route_table_id              = aws_route_table.ipv6_only_private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.main.id
}

resource "aws_route_table_association" "ipv6_only_private" {
  for_each       = aws_subnet.ipv6_only_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.ipv6_only_private.id
}
