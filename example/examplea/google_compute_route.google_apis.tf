# Replaces the default route removed above. Scoped to the Google API VIP range
# rather than 0.0.0.0/0 so it matches what the module's firewall policy allows
# on egress, and so it does not reinstate unrestricted internet egress.
resource "google_compute_route" "google_apis" {
  name             = "firewall-policy-google-apis"
  network          = google_compute_network.firewall.self_link
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
}
