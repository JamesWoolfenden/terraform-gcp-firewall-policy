resource "google_compute_network_firewall_policy_rule" "allow_health_checks" {
  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = var.health_check_priority
  direction       = "INGRESS"
  action          = "allow"
  enable_logging  = true
  description     = "Google load balancer health check probes"

  match {
    src_ip_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = var.health_check_ports
    }
  }
}
