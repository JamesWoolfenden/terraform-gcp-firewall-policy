# terraform-gcp-firewall-policy

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/workflows/Verify/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy)
[![Latest Release](https://img.shields.io/github/release/terraform-gcp-firewall-policy.svg)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-firewall-policy.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for the three firewall policy scopes: a global network
firewall policy and a regional network firewall policy, both associated with
the VPC in var.network, and optionally a hierarchical policy on an organization
or folder. Every rule has logging on. Exercises holden's
google_compute_network_firewall_policy_rule,
google_compute_region_network_firewall_policy_rule and
google_compute_firewall_policy_rule policies.

## Usage

Add **module.firewall_policy.tf** to your code:-

```terraform
module "firewall_policy" {
  source  = "jameswoolfenden/firewall-policy/gcp"
  version = "0.0.1"
  name    = "example"
  network = google_compute_network.firewall.id
  region  = "europe-west2"
  parent  = "folders/123456789012"
}
```

The global policy ships a default-deny egress rule at priority 65000 and an
allow for the Google health check ranges at priority 1000, so anything the
workload actually needs has to be added above 65000. The regional policy ships
a default-deny ingress rule at the same priority. Both policies are associated
with var.network, and an association takes effect immediately — apply it to a
network you can afford to have go quiet.

Attach your own rules to either policy using the name outputs, which are what
the rule resources take as firewall_policy:

```terraform
resource "google_compute_network_firewall_policy_rule" "allow_https" {
  firewall_policy = module.firewall_policy.network_policy_name
  priority        = 2000
  direction       = "EGRESS"
  action          = "allow"
  enable_logging  = true
  description     = "Outbound HTTPS"

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["443"]
    }
  }
}
```

### Private Google Access

The default-deny egress rule blocks Private Google Access. PGA is not a
separate network path: a VM with no external IP reaches the Google API front
ends over ordinary egress, so it is caught by the deny at 65000 like anything
else. Nothing reports this — the subnet still has private_ip_google_access =
true and the routes are untouched — it surfaces as workloads that can no longer
reach googleapis.com, so logging agents stop shipping, GCS reads hang and
Artifact Registry pulls fail.

If the network uses PGA, add an allow above the deny. Which range depends on
how googleapis.com resolves on that network:

```terraform
resource "google_compute_network_firewall_policy_rule" "allow_google_apis" {
  firewall_policy = module.firewall_policy.network_policy_name
  priority        = 1100
  direction       = "EGRESS"
  action          = "allow"
  enable_logging  = true
  description     = "Private Google Access to the Google API front ends"

  match {
    # private.googleapis.com. Use 199.36.153.4/30 instead for
    # restricted.googleapis.com under VPC Service Controls.
    dest_ip_ranges = ["199.36.153.8/30"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["443"]
    }
  }
}
```

Those two ranges only carry the API traffic when a private DNS zone points
googleapis.com at them. On a network still resolving googleapis.com to its
public addresses, PGA egress goes to Google's public API ranges and a narrow
allow will not cover it. Workloads pulling images also need pkg.dev to resolve
and be allowed. Egress to the metadata server at 169.254.169.254 is always
permitted by GCP and needs no rule.

The priorities of the built-in rules are all variables, so a policy that
already has a rule at 1000 or 65000 can move the module's out of the way
rather than colliding at apply time.

var.log_denied_traffic controls logging on the two catch-all deny rules only.
Those match everything no higher priority rule allowed, so on a busy network
they are the highest volume rules in the policy and the dominant Cloud Logging
ingestion cost. It defaults to true; the targeted rules log unconditionally.

The hierarchical policy is only created when var.parent is set, and needs
roles/compute.orgSecurityResourceAdmin at that node. example/exampleb covers
that path.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_firewall_policy.hierarchical](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall_policy) | resource |
| [google_compute_firewall_policy_rule.deny_rdp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy) | resource |
| [google_compute_network_firewall_policy_association.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_association) | resource |
| [google_compute_network_firewall_policy_rule.allow_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.deny_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_region_network_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy) | resource |
| [google_compute_region_network_firewall_policy_association.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_association) | resource |
| [google_compute_region_network_firewall_policy_rule.deny_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_deny_priority"></a> [default\_deny\_priority](#input\_default\_deny\_priority) | Priority of the catch-all deny rules in the global and regional policies. Rules the workload needs must sit above this, that is at a lower number | `number` | `65000` | no |
| <a name="input_deny_rdp_priority"></a> [deny\_rdp\_priority](#input\_deny\_rdp\_priority) | Priority of the RDP deny rule in the hierarchical policy | `number` | `1000` | no |
| <a name="input_description"></a> [description](#input\_description) | Description applied to each firewall policy | `string` | `"Managed by Terraform"` | no |
| <a name="input_health_check_ports"></a> [health\_check\_ports](#input\_health\_check\_ports) | TCP ports Google health check probes are allowed to reach | `list(string)` | <pre>[<br/>  "80",<br/>  "443"<br/>]</pre> | no |
| <a name="input_health_check_priority"></a> [health\_check\_priority](#input\_health\_check\_priority) | Priority of the rule allowing the Google health check ranges into the global policy | `number` | `1000` | no |
| <a name="input_log_denied_traffic"></a> [log\_denied\_traffic](#input\_log\_denied\_traffic) | Log hits on the catch-all deny rules. These match everything no higher priority rule allowed, so on a busy network they are the highest volume rules in the policy and the dominant Cloud Logging ingestion cost. Turning this off keeps the deny, drops the record of it | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name of the firewall policies | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Self-link of the VPC network the global network firewall policy is associated with | `string` | n/a | yes |
| <a name="input_parent"></a> [parent](#input\_parent) | Organization or folder the hierarchical firewall policy attaches to, organizations/<id> or folders/<id>. Empty to create no hierarchical policy | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of the regional network firewall policy | `string` | `"europe-west2"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_hierarchical_policy_id"></a> [hierarchical\_policy\_id](#output\_hierarchical\_policy\_id) | ID of the hierarchical firewall policy, null when var.parent is unset |
| <a name="output_network_policy_id"></a> [network\_policy\_id](#output\_network\_policy\_id) | ID of the global network firewall policy |
| <a name="output_network_policy_name"></a> [network\_policy\_name](#output\_network\_policy\_name) | Name of the global network firewall policy, for attaching additional rules |
| <a name="output_region_policy_id"></a> [region\_policy\_id](#output\_region\_policy\_id) | ID of the regional network firewall policy |
| <a name="output_region_policy_name"></a> [region\_policy\_name](#output\_region\_policy\_name) | Name of the regional network firewall policy, for attaching additional rules |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/issues).

## Copyrights

Copyright © 2019-2026 [Jim Woolfenden](https://github.com/JamesWoolfenden)

## License

See [LICENSE](LICENSE) for full details.


<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "compute.firewallPolicies.create",
    "compute.firewallPolicies.delete",
    "compute.firewallPolicies.get",
    "compute.firewallPolicies.update",
    "compute.regionFirewallPolicies.create",
    "compute.regionFirewallPolicies.delete",
    "compute.regionFirewallPolicies.get",
    "compute.regionFirewallPolicies.update"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "compute.firewallPolicies.get",
    "compute.regionFirewallPolicies.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->
