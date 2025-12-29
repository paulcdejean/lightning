# This subnet is not private because it has private IP addresses.
# It's private because it routes internet traffic through an egress only gateway.

resource "aws_subnet" "ipv6_only_private" {
  for_each                                       = local.azs
  vpc_id                                         = data.aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_native                                    = true
  ipv6_cidr_block                                = "${local.vpc_ipv6space_array[0]}:${local.vpc_ipv6space_array[1]}:${local.vpc_ipv6space_array[2]}:${format("%x", parseint(local.vpc_ipv6space_array[3], 16) + parseint("${each.value}${local.hexnumber_ipv6_only_private}", 16))}::/64"
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
