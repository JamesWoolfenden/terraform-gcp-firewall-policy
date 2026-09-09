resource "google_tags_tag_key" "role" {
  parent      = "projects/${data.google_project.current.project_id}"
  short_name  = "firewall-policy-role"
  description = "Role a VM plays behind the firewall policy"
}
