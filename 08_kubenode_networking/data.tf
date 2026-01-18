data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Calculation of the VPC ipv6 cidr from the hexnumber provided in the workspace.
locals {
  vpc_ipv6_cidr_array      = split(":", trimsuffix(data.aws_vpc.main.ipv6_cidr_block, "::/56"))
  ipv6_prefix              = "${local.vpc_ipv6_cidr_array[0]}:${local.vpc_ipv6_cidr_array[1]}:${local.vpc_ipv6_cidr_array[2]}:"
  ipv6_cidr_fourth_numeric = parseint(local.vpc_ipv6_cidr_array[3], 16)
  vpc_ipv4_cidr_array      = split(".", data.aws_vpc.main.cidr_block)
  ipv4_cidr_prefix         = "${local.vpc_ipv4_cidr_array[0]}.${local.vpc_ipv4_cidr_array[1]}."
}

locals {
  azs = {
    for zone in data.aws_availability_zones.available.names : zone => substr(zone, -1, 1)
  }
}
