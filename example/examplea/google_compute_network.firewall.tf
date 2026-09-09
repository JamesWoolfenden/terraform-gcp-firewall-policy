# holden:ignore:HLD_GCP_093 — this network is guarded by firewall policies via
# module.firewall_policy, not google_compute_firewall rules; that is the whole
# point of the module.
resource "google_compute_network" "firewall" {
  name                            = "firewall-policy-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}
