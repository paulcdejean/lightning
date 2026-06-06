output "ipv6" {
  value = local.workspace.enabled ? aws_instance.bastion.ipv6_addresses[0] : null
}
