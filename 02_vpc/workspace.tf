locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket     = "lightning-593941967609-us-east-2-an
      ipv4_cidr_prefix = "10.10."
      ipv4_cidr_suffix = "0.0/16"
      # Our /52 can have 16 environments inside it.
      ipv6_hexnumber = "5"
    }
  }
}
