resource "google_compute_network_firewall_policy" "main" {
  name        = "${var.name}-global"
  description = var.description
}
