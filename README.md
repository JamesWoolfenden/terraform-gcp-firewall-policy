# terraform-gcp-firewall-policy

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/workflows/Verify/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy)
[![Latest Release](https://img.shields.io/github/release/terraform-gcp-firewall-policy.svg)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-firewall-policy.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-firewall-policy/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for the three firewall policy scopes: a global network
firewall policy and a regional network firewall policy, both associated with
the VPC in var.network, and optionally a hierarchical policy on an organization
or folder. Every rule logs, the catch-all denies conditionally. Exercises
holden's google_compute_network_firewall_policy_rule,
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

The global policy default-denies both directions, at 65000 for egress and
65001 for ingress, so anything the workload actually needs has to be added
above those. Above the denies it ships an RDP deny at 900, an allow for the
Google health check ranges at 1000, and an allow for Private Google Access at
1050. The regional policy carries its own default-deny ingress at 65000.

Both policies are associated with var.network, and an association takes effect
immediately — apply it to a network you can afford to have go quiet.

Firewall policies are evaluated hierarchical first, then global, then regional,
then VPC firewall rules, and the first rule that matches with allow or deny
ends evaluation. Two consequences worth knowing. The global default-denies
apply network-wide, so they shadow the regional policy's ingress deny in the
default configuration; that rule is kept as a backstop for its own region.
And because the policy layer is evaluated before VPC firewall rules, these
denies take precedence over any permissive google_compute_firewall rules
already on the network.

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

The module ships the egress allow PGA needs, at priority 1050 for
199.36.153.8/30, so a default deployment does not break it. Set
var.google_apis_egress_ranges to ["199.36.153.4/30"] for
restricted.googleapis.com under VPC Service Controls, or to [] to create no
rule at all.

It is worth knowing why that rule is there. PGA is not a separate network path:
a VM with no external IP reaches the Google API front ends over ordinary
egress, so a catch-all egress deny drops it like anything else. Nothing reports
that — the subnet still has private_ip_google_access = true and the routes are
untouched — it surfaces later as workloads that cannot reach googleapis.com, so
logging agents stop shipping, GCS reads hang and Artifact Registry pulls fail.

That VIP range only carries the API traffic when a private DNS zone points
googleapis.com at it. On a network still resolving googleapis.com to its public
addresses, this narrow allow does not cover it and the workload needs a broader
egress allow instead. Workloads pulling images also need pkg.dev to resolve and
be allowed. Egress to the metadata server at 169.254.169.254 is always
permitted by GCP and needs no rule.

The health check allow applies to every VM on the network unless you scope it.
Pass secure tag values in var.health_check_target_tags to limit it to the
backends actually behind a load balancer; example/examplea builds a tag key and
value and wires them in.

Both examples also show the routing side of this. They delete the default
route, replace it with one scoped to 199.36.153.8/30 rather than 0.0.0.0/0 so
the route matches what the firewall policy allows on egress, and add a private
googleapis.com zone so the API names resolve to the range that route covers. A
broad replacement route would reinstate the unrestricted egress the deletion
was meant to remove.

The priorities of the built-in rules are all variables, so a policy that
already has a rule at one of the numbers above can move the module's out of the
way rather than colliding at apply time. GCP requires priorities to be unique
within a policy, which is why the global policy's two default-denies sit at
65000 and 65001 rather than sharing one number.

var.log_denied_traffic controls logging on the three catch-all deny rules only.
Those match everything no higher priority rule allowed, so on a busy network
they are the highest volume rules in the policy and the dominant Cloud Logging
ingestion cost. It defaults to true; the targeted rules, including the RDP
deny, log unconditionally.

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
| [google_compute_network_firewall_policy_rule.allow_google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.allow_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.deny_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.deny_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_network_firewall_policy_rule.deny_rdp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_region_network_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy) | resource |
| [google_compute_region_network_firewall_policy_association.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_association) | resource |
| [google_compute_region_network_firewall_policy_rule.deny_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_deny_priority"></a> [default\_deny\_priority](#input\_default\_deny\_priority) | Priority of the catch-all deny rules in the global and regional policies. Rules the workload needs must sit above this, that is at a lower number | `number` | `65000` | no |
| <a name="input_deny_rdp_priority"></a> [deny\_rdp\_priority](#input\_deny\_rdp\_priority) | Priority of the RDP deny rule in the hierarchical policy | `number` | `1000` | no |
| <a name="input_description"></a> [description](#input\_description) | Description applied to each firewall policy | `string` | `"Managed by Terraform"` | no |
| <a name="input_global_deny_ingress_priority"></a> [global\_deny\_ingress\_priority](#input\_global\_deny\_ingress\_priority) | Priority of the catch-all ingress deny in the global policy. Rule priorities are unique within a policy, so this cannot reuse var.default\_deny\_priority, which the global egress deny already holds | `number` | `65001` | no |
| <a name="input_global_deny_rdp_priority"></a> [global\_deny\_rdp\_priority](#input\_global\_deny\_rdp\_priority) | Priority of the RDP deny in the global policy. Sits above var.health\_check\_priority so the deny is evaluated first, and must differ from it because rule priorities are unique within a policy | `number` | `900` | no |
| <a name="input_google_apis_egress_ranges"></a> [google\_apis\_egress\_ranges](#input\_google\_apis\_egress\_ranges) | Destinations the Private Google Access egress allow covers. Defaults to the private.googleapis.com VIP range; use 199.36.153.4/30 for restricted.googleapis.com under VPC Service Controls. Empty creates no rule, which leaves the catch-all deny to drop Google API traffic | `list(string)` | <pre>[<br/>  "199.36.153.8/30"<br/>]</pre> | no |
| <a name="input_google_apis_priority"></a> [google\_apis\_priority](#input\_google\_apis\_priority) | Priority of the Private Google Access egress allow in the global policy. Must sit above var.default\_deny\_priority and differ from every other rule in that policy | `number` | `1050` | no |
| <a name="input_health_check_ports"></a> [health\_check\_ports](#input\_health\_check\_ports) | TCP ports Google health check probes are allowed to reach | `list(string)` | <pre>[<br/>  "80",<br/>  "443"<br/>]</pre> | no |
| <a name="input_health_check_priority"></a> [health\_check\_priority](#input\_health\_check\_priority) | Priority of the rule allowing the Google health check ranges into the global policy | `number` | `1000` | no |
| <a name="input_health_check_target_tags"></a> [health\_check\_target\_tags](#input\_health\_check\_target\_tags) | Secure tag values, each of the form tagValues/NUMERIC\_ID, that the health check allow is scoped to. Empty, the default, leaves that allow applying to every VM on the network rather than only load balanced backends | `list(string)` | `[]` | no |
| <a name="input_log_denied_traffic"></a> [log\_denied\_traffic](#input\_log\_denied\_traffic) | Log hits on the catch-all deny rules. These match everything no higher priority rule allowed, so on a busy network they are the highest volume rules in the policy and the dominant Cloud Logging ingestion cost. Turning this off keeps the deny, drops the record of it | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name of the firewall policies | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Self-link of the VPC network the global network firewall policy is associated with | `string` | n/a | yes |
| <a name="input_parent"></a> [parent](#input\_parent) | Organization or folder the hierarchical firewall policy attaches to, organizations/ID or folders/ID. Empty to create no hierarchical policy | `string` | `""` | no |
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
