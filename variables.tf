variable "name" {
  type        = string
  description = "Base name of the firewall policies"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,40}$", var.name))
    error_message = "var.name must be lowercase, start with a letter and be at most 41 characters"
  }
}

variable "network" {
  type        = string
  description = "Self-link of the VPC network the global network firewall policy is associated with"

  validation {
    condition     = length(trimspace(var.network)) > 0
    error_message = "var.network must be a non-empty string"
  }
}

variable "region" {
  type        = string
  description = "Region of the regional network firewall policy"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "parent" {
  type        = string
  description = "Organization or folder the hierarchical firewall policy attaches to, organizations/<id> or folders/<id>. Empty to create no hierarchical policy"
  default     = ""

  validation {
    condition     = var.parent == "" || can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "var.parent must be organizations/<id> or folders/<id>"
  }
}

variable "health_check_ports" {
  type        = list(string)
  description = "TCP ports Google health check probes are allowed to reach"
  default     = ["80", "443"]

  validation {
    condition     = alltrue([for p in var.health_check_ports : can(regex("^[0-9]+(-[0-9]+)?$", p))])
    error_message = "var.health_check_ports entries must be ports or port ranges"
  }
}

variable "description" {
  type        = string
  description = "Description applied to each firewall policy"
  default     = "Managed by Terraform"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}

variable "log_denied_traffic" {
  type        = bool
  description = "Log hits on the catch-all deny rules. These match everything no higher priority rule allowed, so on a busy network they are the highest volume rules in the policy and the dominant Cloud Logging ingestion cost. Turning this off keeps the deny, drops the record of it"
  default     = true
}

variable "health_check_priority" {
  type        = number
  description = "Priority of the rule allowing the Google health check ranges into the global policy"
  default     = 1000

  validation {
    condition     = var.health_check_priority >= 0 && var.health_check_priority <= 2147483647
    error_message = "var.health_check_priority must be between 0 and 2147483647"
  }
}

variable "deny_rdp_priority" {
  type        = number
  description = "Priority of the RDP deny rule in the hierarchical policy"
  default     = 1000

  validation {
    condition     = var.deny_rdp_priority >= 0 && var.deny_rdp_priority <= 2147483647
    error_message = "var.deny_rdp_priority must be between 0 and 2147483647"
  }
}

variable "default_deny_priority" {
  type        = number
  description = "Priority of the catch-all deny rules in the global and regional policies. Rules the workload needs must sit above this, that is at a lower number"
  default     = 65000

  validation {
    condition     = var.default_deny_priority >= 0 && var.default_deny_priority <= 2147483647
    error_message = "var.default_deny_priority must be between 0 and 2147483647"
  }
}
