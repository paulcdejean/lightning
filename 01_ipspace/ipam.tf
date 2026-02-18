data "aws_region" "current" {}

resource "aws_vpc_ipam" "main" {
  tier        = "free"
  description = "lightning-${tofu.workspace}"
  operating_regions {
    region_name = data.aws_region.current.region
  }

  tags = {
    lightning = "true"
  }
}

resource "aws_vpc_ipam_pool" "public" {
  address_family   = "ipv6"
  ipam_scope_id    = aws_vpc_ipam.main.public_default_scope_id
  locale           = data.aws_region.current.region
  public_ip_source = "amazon"
  aws_service      = "ec2"
  tags = {
    lightning = "true"
  }
}

resource "aws_vpc_ipam_pool_cidr" "public" {
  ipam_pool_id = aws_vpc_ipam_pool.public.id
  # The only size amazon will give you without a limit increase.
  netmask_length = 52
}
