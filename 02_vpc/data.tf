data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = {
    for zone in data.aws_availability_zones.available.names : zone => substr(zone, -1, 1)
  }
}
