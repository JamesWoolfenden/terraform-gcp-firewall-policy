output "network_policy_id" {
  value       = google_compute_network_firewall_policy.main.id
  description = "ID of the global network firewall policy"
}

output "region_policy_id" {
  value       = google_compute_region_network_firewall_policy.main.id
  description = "ID of the regional network firewall policy"
}

output "hierarchical_policy_id" {
  value       = try(google_compute_firewall_policy.hierarchical[0].id, null)
  description = "ID of the hierarchical firewall policy, null when var.parent is unset"
}

output "network_policy_name" {
  value       = google_compute_network_firewall_policy.main.name
  description = "Name of the global network firewall policy, for attaching additional rules"
}

output "region_policy_name" {
  value       = google_compute_region_network_firewall_policy.main.name
  description = "Name of the regional network firewall policy, for attaching additional rules"
}
