resource "google_compute_network_firewall_policy_association" "main" {
  name              = "${var.name}-association"
  attachment_target = var.network
  firewall_policy   = google_compute_network_firewall_policy.main.name
}
