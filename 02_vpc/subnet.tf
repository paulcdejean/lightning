data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = {
    for k, v in data.aws_availability_zones.available.names : v => k
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

locals {
  vpc_ipv6space       = data.aws_vpc.main.ipv6_cidr_block
  vpc_ipv6space_array = split(":", trimsuffix(local.vpc_ipv6space, "::/56"))
  vpc_ipv4space       = data.aws_vpc.main.cidr_block
  vpc_ipv4space_array = split(".", trimsuffix(local.vpc_ipv4space, "/16"))
}

# There's 256 ipv6 subnets of size /64 that can fit inside the VPC.
# That's two hex numbers.
# We'll use one for the availability zone, and the second for the type.
# The list of types with their hexnumbers is below.
# We can also fit 256 ipv4 subnets of size /24.
# We use the same method, however it will look a bit strange because those cidrs are represented in decimal.
locals {
  hexnumber_ipv6_only_public  = "1"
  hexnumber_dualstack_public  = "2"
  hexnumber_ipv6_only_private = "3"
}
