resource "google_compute_firewall_policy_rule" "deny_rdp" {
  count = local.create_hierarchical ? 1 : 0

  firewall_policy = google_compute_firewall_policy.hierarchical[0].id
  priority        = var.deny_rdp_priority
  direction       = "INGRESS"
  action          = "deny"
  enable_logging  = true
  description     = "RDP from the internet is never allowed below this node"

  match {
    src_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["3389"]
    }
  }
}
