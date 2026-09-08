resource "google_compute_region_network_firewall_policy_association" "main" {
  name              = "${var.name}-regional-association"
  region            = var.region
  attachment_target = var.network
  firewall_policy   = google_compute_region_network_firewall_policy.main.name
}
