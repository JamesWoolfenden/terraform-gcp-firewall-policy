# The egress counterpart to allow_health_checks: without this the catch-all
# egress deny drops Private Google Access and every call to googleapis.com
# fails, with routes and DNS untouched and nothing in a plan to show it.
resource "google_compute_network_firewall_policy_rule" "allow_google_apis" {
  count = length(var.google_apis_egress_ranges) > 0 ? 1 : 0

  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = var.google_apis_priority
  direction       = "EGRESS"
  action          = "allow"
  enable_logging  = true
  description     = "Private Google Access to the Google API front ends"

  match {
    dest_ip_ranges = var.google_apis_egress_ranges

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["443"]
    }
  }
}
