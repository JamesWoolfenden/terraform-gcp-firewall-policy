resource "google_compute_network_firewall_policy_rule" "deny_egress" {
  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = var.default_deny_priority
  direction       = "EGRESS"
  action          = "deny"
  enable_logging  = var.log_denied_traffic
  description     = "Default deny for egress not matched by a higher priority rule"

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}
