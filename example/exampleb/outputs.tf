output "hierarchical_policy_id" {
  value       = module.firewall_policy.hierarchical_policy_id
  description = "ID of the hierarchical firewall policy"
}

output "network_policy_name" {
  value       = module.firewall_policy.network_policy_name
  description = "Name of the global network firewall policy"
}
