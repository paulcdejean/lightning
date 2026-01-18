data "aws_vpc_ipam_pools" "lightning" {
  filter {
    name   = "tag:lightning"
    values = ["true"]
  }
}

data "aws_vpc_ipam_pool_cidrs" "lightning" {
  ipam_pool_id = local.ipspace_pool
}

# Calculation of the VPC ipv6 cidr from the hexnumber provided in the workspace.
locals {
  ipspace            = one(data.aws_vpc_ipam_pool_cidrs.lightning.ipam_pool_cidrs).cidr
  ipspace_pool       = one(data.aws_vpc_ipam_pools.lightning.ipam_pools).id
  ipv6_ipspace_array = split(":", trimsuffix(local.ipspace, "::/52"))
  # The prefix is the first 3 ipv6 segments.
  ipv6_prefix              = "${local.ipv6_ipspace_array[0]}:${local.ipv6_ipspace_array[1]}:${local.ipv6_ipspace_array[2]}:"
  ipv6_cidr_fourth_numeric = parseint(local.ipv6_ipspace_array[3], 16) + parseint("${local.workspace.ipv6_hexnumber}00", 16)
  ipv6_cidr_fourth_string  = format("%x", local.ipv6_cidr_fourth_numeric)
  ipv6_cidr                = "${local.ipv6_prefix}${local.ipv6_cidr_fourth_string}::/56"
}

resource "aws_vpc" "main" {
  cidr_block        = "${local.workspace.ipv4_cidr_prefix}${local.workspace.ipv4_cidr_suffix}"
  ipv6_cidr_block   = local.ipv6_cidr
  ipv6_ipam_pool_id = local.ipspace_pool
  tags = {
    Name = "lightning-${tofu.workspace}"
  }
  lifecycle {
    ignore_changes = [
      ipv6_netmask_length
    ]
  }
}
