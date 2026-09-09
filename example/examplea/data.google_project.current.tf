# Tag keys are project scoped; resolve the project from the ambient credentials
# rather than hardcoding an id into the example.
data "google_project" "current" {}
