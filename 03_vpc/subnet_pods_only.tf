locals {
  pods_only_ipv6_ranges = {
    for k, v in local.azs : k =>
    provider::toml::decode(file("${path.module}/network.toml")).ipv6["pods-only-${v}"]
  }
  pods_only_ipv6_blocks = {
    for k, v in local.pods_only_ipv6_ranges : k =>
    "${local.ipv6_prefix}${format("%x", local.ipv6_cidr_fourth_numeric + v)}::/64"
  }
}

resource "aws_subnet" "pods_only" {
  for_each                                       = local.pods_only_ipv6_blocks
  vpc_id                                         = aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_native                                    = true
  ipv6_cidr_block                                = each.value
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  tags = {
    Name = "lightning-${tofu.workspace}-pods-only-${each.key}"
  }
}

resource "aws_route_table" "pods_only" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-pods-only"
  }
}

resource "aws_route" "pods_only_to_internet" {
  route_table_id              = aws_route_table.pods_only.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "pods_only" {
  for_each       = aws_subnet.pods_only
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pods_only.id
}
