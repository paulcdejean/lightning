locals {
  subnet_slash_number = {
    for az, cidr in local.kubenode_small_ipv4_blocks :
    az => split("/", cidr)[1]
  }
  subnet_eip_count = {
    for k, v in local.subnet_slash_number :
    k => pow(2, 31 - tonumber(v)) - 1 # last address is reserved, we need to cover the entire "top half" so DHCP doesn't assign it
  }
  subnet_cidr_no_slash = {
    for az, cidr in local.kubenode_small_ipv4_blocks :
    az => trimsuffix(cidr, "/${local.subnet_slash_number[az]}")
  }
  subnet_cidr_array = {
    for k, v in local.subnet_cidr_no_slash :
    k => split(".", v)
  }
  subnet_starting_number = {
    for k, v in local.subnet_cidr_array :
    k => tonumber(v[2]) * 256 + tonumber(v[3])
  }
  subnet_eip_starting_number = {
    for k, v in local.subnet_starting_number :
    k => v + local.subnet_eip_count[k] + 1 # last address is reserved, we need to cover the entire "top half" so DHCP doesn't assign it
  }
  # Sanity check.
  subnet_eip_first_address = {
    for k, v in local.subnet_eip_starting_number :
    k => "${local.subnet_cidr_array[k][0]}.${local.subnet_cidr_array[k][1]}.${floor(v / 256)}.${v % 256}"
  }
  subnet_eip_ips_numeric = {
    for k, v in local.subnet_eip_starting_number :
    k => range(v, v + local.subnet_eip_count[k])
  }
  # A bit "the rest of the owl" sorry...
  subnet_eips_final = merge([
    for az, addr_list in local.subnet_eip_ips_numeric :
    {
      for addr in addr_list :
      "${local.subnet_cidr_array[az][0]}.${local.subnet_cidr_array[az][1]}.${floor(addr / 256)}.${addr % 256}" => {
        az       = az
        ipv6_hex = format("%x", addr)
      }
    }
  ]...)
}

resource "aws_network_interface" "kubenode_small_secondary" {
  # for_each = local.subnet_eips_final
  # subnet_id       = aws_subnet.kubenode_small[each.value.az].id
  # private_ips     = [each.key]
  # security_groups = [aws_security_group.kubenode.id]
  for_each        = local.subnet_eips_final
  subnet_id       = aws_subnet.kubenode_small[each.value.az].id
  private_ips     = [each.key]
  security_groups = [aws_security_group.kubenode.id]
  ipv6_prefixes   = ["${trimsuffix(aws_subnet.kubenode_small[each.value.az].ipv6_cidr_block, "::/64")}:${each.value.ipv6_hex}::/80"]
  tags = {
    Name = "lightning-kubenode-secondary-${tofu.workspace}-${each.key}"
  }
}
