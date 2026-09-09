# Without this the API names still resolve to public addresses the narrow route
# above does not reach, and every Google API call fails.
resource "google_dns_managed_zone" "googleapis" {
  name       = "firewall-policy-hierarchical-googleapis"
  dns_name   = "googleapis.com."
  visibility = "private"

  cloud_logging_config {
    enable_logging = true
  }

  private_visibility_config {
    networks {
      network_url = google_compute_network.firewall.id
    }
  }
}
