resource "google_compute_firewall_policy" "hierarchical" {
  count = local.create_hierarchical ? 1 : 0

  parent      = var.parent
  short_name  = "${var.name}-hierarchical"
  description = var.description
}
