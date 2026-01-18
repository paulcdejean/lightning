data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["lightning-${tofu.workspace}"]
  }
}

locals {
  azs = {
    for zone in data.aws_availability_zones.available.names : zone => substr(zone, -1, 1)
  }
}
