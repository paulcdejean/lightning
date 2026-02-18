locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      ipv4_cidr_prefix = "10.10."
      ipv4_cidr_suffix = "0.0/16"
      # Our /52 can have 16 environments inside it.
      ipv6_hexnumber = "1" # Skipping 0 because it makes things visually easier for me.
    }
  }
}
