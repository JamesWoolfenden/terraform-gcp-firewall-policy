resource "google_compute_network" "firewall" {
  name                    = "firewall-policy-network"
  auto_create_subnetworks = false
}
