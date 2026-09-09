# A narrow route only carries Google API traffic if googleapis.com resolves to
# the range it covers. Without this zone the names still resolve to public
# addresses the route does not reach, and every API call fails.
resource "google_dns_managed_zone" "googleapis" {
  name       = "firewall-policy-googleapis"
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
