locals {
  ipv6only_public_ipv6_ranges = {
    for k, v in local.azs : k =>
    provider::toml::decode(file("${path.module}/network.toml")).ipv6["ipv6only-public-${v}"]
  }
  ipv6only_public_ipv6_blocks = {
    for k, v in local.ipv6only_public_ipv6_ranges : k =>
    "${local.ipv6_prefix}${format("%x", local.ipv6_cidr_fourth_numeric + v)}::/64"
  }
}

resource "aws_subnet" "ipv6_only_public" {
  for_each                                       = local.ipv6only_public_ipv6_blocks
  vpc_id                                         = aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_native                                    = true
  ipv6_cidr_block                                = each.value
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  tags = {
    Name = "lightning-${tofu.workspace}-ipv6only-public-${each.key}"
  }
}

resource "aws_route_table" "ipv6_only_public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-ipv6only-public"
  }
}

resource "aws_route" "ipv6_only_public_to_internet" {
  route_table_id              = aws_route_table.ipv6_only_public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "ipv6_only_public" {
  for_each       = aws_subnet.ipv6_only_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.ipv6_only_public.id
}
