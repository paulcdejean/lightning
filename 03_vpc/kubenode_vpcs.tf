# These VPCs are disconnected from the network!
# The purpose of them, is to allocate a ipv4 in a range of 0 to 65536.
# Then we map that ipv4 to an ipv6 range that is inside the network!
# Because they're disconnected from the network, we use automatic ipv6 allocation.

resource "aws_vpc" "kubenode" {
  for_each = local.azs
  # Yes this is hardcoded. Yes the VPCs will overlap. Again though this VPC is isolated.
  cidr_block                       = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "lightning-kubenode-${tofu.workspace}-${each.key}"
  }
}

resource "aws_subnet" "kubenode" {
  for_each                        = aws_vpc.kubenode
  vpc_id                          = each.value.id
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  cidr_block                      = each.value.cidr_block
  assign_ipv6_address_on_creation = true
  tags = {
    Name = "lightning-kubenode-${tofu.workspace}-${each.key}"
  }
}

resource "aws_egress_only_internet_gateway" "kubenode" {
  for_each = aws_vpc.kubenode
  vpc_id   = each.value.id
  tags = {
    Name = "lightning-kubenode-${tofu.workspace}-${each.key}"
  }
}


resource "aws_route" "kubenode_to_internet" {
  for_each                    = aws_vpc.kubenode
  route_table_id              = each.value.main_route_table_id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.kubenode[each.key].id
}
