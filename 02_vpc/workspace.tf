locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      region           = "us-east-2"
      ipv4_cidr_prefix = "10.10."
      ipv4_cidr_suffix = "0.0/16"
      # Our /52 can have 16 environments inside it.
      ipv6_hexnumber = "5"
    }
  }
}
