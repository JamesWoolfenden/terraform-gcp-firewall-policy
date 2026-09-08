# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for expansion
module "firewall_policy" {
  source  = "../../"
  name    = "example-hierarchical"
  network = google_compute_network.firewall.id
  region  = "europe-west2"
  parent  = var.parent
}
