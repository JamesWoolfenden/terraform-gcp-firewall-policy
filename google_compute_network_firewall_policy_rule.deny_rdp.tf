# The hierarchical policy's RDP deny only exists when var.parent is set. This one
# always does, so the module denies inbound RDP in its default configuration too.
# Sits above the health check allow so a dangerous port is refused first.
resource "google_compute_network_firewall_policy_rule" "deny_rdp" {
  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = var.global_deny_rdp_priority
  direction       = "INGRESS"
  action          = "deny"
  enable_logging  = true
  description     = "RDP from the internet is never allowed on this network"

  match {
    src_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["3389"]
    }
  }
}
