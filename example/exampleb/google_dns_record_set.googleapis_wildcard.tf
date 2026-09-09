resource "google_dns_record_set" "googleapis_wildcard" {
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.googleapis.com."]
}
