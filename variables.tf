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
  description = "Organization or folder the hierarchical firewall policy attaches to, organizations/ID or folders/ID. Empty to create no hierarchical policy"
  default     = ""

  validation {
    condition     = var.parent == "" || can(regex("^(organizations|folders)/[0-9]+$", var.parent))
    error_message = "var.parent must be organizations/ID or folders/ID"
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

variable "global_deny_ingress_priority" {
  type        = number
  description = "Priority of the catch-all ingress deny in the global policy. Rule priorities are unique within a policy, so this cannot reuse var.default_deny_priority, which the global egress deny already holds"
  default     = 65001

  validation {
    condition     = var.global_deny_ingress_priority >= 0 && var.global_deny_ingress_priority <= 2147483647
    error_message = "var.global_deny_ingress_priority must be between 0 and 2147483647"
  }
}

variable "global_deny_rdp_priority" {
  type        = number
  description = "Priority of the RDP deny in the global policy. Sits above var.health_check_priority so the deny is evaluated first, and must differ from it because rule priorities are unique within a policy"
  default     = 900

  validation {
    condition     = var.global_deny_rdp_priority >= 0 && var.global_deny_rdp_priority <= 2147483647
    error_message = "var.global_deny_rdp_priority must be between 0 and 2147483647"
  }
}

variable "health_check_target_tags" {
  type        = list(string)
  description = "Secure tag values, each of the form tagValues/NUMERIC_ID, that the health check allow is scoped to. Empty, the default, leaves that allow applying to every VM on the network rather than only load balanced backends"
  default     = []

  validation {
    condition     = alltrue([for t in var.health_check_target_tags : can(regex("^tagValues/[0-9]+$", t))])
    error_message = "var.health_check_target_tags entries must look like tagValues/281475471241234"
  }
}

variable "google_apis_egress_ranges" {
  type        = list(string)
  description = "Destinations the Private Google Access egress allow covers. Defaults to the private.googleapis.com VIP range; use 199.36.153.4/30 for restricted.googleapis.com under VPC Service Controls. Empty creates no rule, which leaves the catch-all deny to drop Google API traffic"
  default     = ["199.36.153.8/30"]

  validation {
    condition     = alltrue([for r in var.google_apis_egress_ranges : can(cidrnetmask(r))])
    error_message = "var.google_apis_egress_ranges entries must be valid CIDR blocks"
  }
}

variable "google_apis_priority" {
  type        = number
  description = "Priority of the Private Google Access egress allow in the global policy. Must sit above var.default_deny_priority and differ from every other rule in that policy"
  default     = 1050

  validation {
    condition     = var.google_apis_priority >= 0 && var.google_apis_priority <= 2147483647
    error_message = "var.google_apis_priority must be between 0 and 2147483647"
  }
}
