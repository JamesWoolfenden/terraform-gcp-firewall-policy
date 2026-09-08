variable "parent" {
  type        = string
  description = "Organization or folder the hierarchical firewall policy attaches to. The default is a placeholder so CI can plan the hierarchical code path without an org-scoped identity, override it to apply"
  default     = "folders/123456789012"

  validation {
    condition     = can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "var.parent must be organizations/<id> or folders/<id>"
  }
}
