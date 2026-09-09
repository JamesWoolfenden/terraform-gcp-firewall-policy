# Replaces the default route removed above, scoped to the Google API VIP range
# so it matches what the module's firewall policy allows on egress.
resource "google_compute_route" "google_apis" {
  name             = "firewall-policy-hierarchical-google-apis"
  network          = google_compute_network.firewall.self_link
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
}
