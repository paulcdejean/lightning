resource "aws_subnet" "dualstack_private" {
  for_each                                       = local.azs
  vpc_id                                         = data.aws_vpc.main.id
  availability_zone                              = each.key
  ipv6_cidr_block                                = "${local.vpc_ipv6space_array[0]}:${local.vpc_ipv6space_array[1]}:${local.vpc_ipv6space_array[2]}:${format("%x", parseint(local.vpc_ipv6space_array[3], 16) + parseint("${each.value}${local.hexnumber_dualstack_private}", 16))}::/64"
  cidr_block                                     = "${local.vpc_ipv4space_array[0]}.${local.vpc_ipv4space_array[1]}.${parseint("${each.value}${local.hexnumber_dualstack_private}", 16)}.0/24"
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = false
  enable_resource_name_dns_a_record_on_launch    = true
  tags = {
    Name = "lightning-${tofu.workspace}-dualstack-private-${each.key}"
  }
}

resource "aws_route_table" "dualstack_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "lightning-${tofu.workspace}-dualstack-private"
  }
}

resource "aws_route" "dualstack_private_ipv6_to_internet" {
  route_table_id              = aws_route_table.dualstack_private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.main.id
}

resource "aws_route_table_association" "dualstack_private" {
  for_each       = aws_subnet.dualstack_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dualstack_private.id
}
