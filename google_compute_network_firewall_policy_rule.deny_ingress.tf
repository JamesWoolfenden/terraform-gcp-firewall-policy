# The global policy is evaluated before the regional one, so this shadows
# google_compute_region_network_firewall_policy_rule.deny_ingress in the default
# configuration. The regional rule is kept as a backstop for its own region.
resource "google_compute_network_firewall_policy_rule" "deny_ingress" {
  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = var.global_deny_ingress_priority
  direction       = "INGRESS"
  action          = "deny"
  enable_logging  = var.log_denied_traffic
  description     = "Default deny for ingress not matched by a higher priority rule"

  match {
    src_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}
