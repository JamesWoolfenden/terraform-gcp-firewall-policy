# Scopes the module's health check allow to load balanced backends, so the
# Google prober ranges reach only VMs carrying this tag rather than every VM
# on the network.
resource "google_tags_tag_value" "lb_backend" {
  parent      = google_tags_tag_key.role.id
  short_name  = "lb-backend"
  description = "VMs behind a load balancer, probed by Google health checks"
}
