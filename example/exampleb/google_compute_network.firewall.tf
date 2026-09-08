# holden:ignore:HLD_GCP_093 — this network is guarded by firewall policies, not
# google_compute_firewall rules; that is the whole point of the module.
resource "google_compute_network" "firewall" {
  name                    = "firewall-policy-hierarchical-network"
  auto_create_subnetworks = false
}
