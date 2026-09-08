resource "google_compute_region_network_firewall_policy" "main" {
  name        = "${var.name}-regional"
  region      = var.region
  description = var.description
}
