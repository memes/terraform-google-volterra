# F5 Distributed Cloud GCP VPC Site module

![GitHub release](https://img.shields.io/github/v/release/memes/terraform-google-volterra?sort=semver)
![Maintenance](https://img.shields.io/maintenance/yes/2024)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

This Terraform module creates an opinionated F5 Distributed Cloud [GCP VPC Site].

> NOTE: The intent of this module is to easily repeat a common use-case when
> deploying an F5 XC [GCP VPC Site]. It does not expose every option available.

## Opinions

1. The F5XC Site will use *existing* VPC network(s)
2. The F5XC Site will be configured as an *ingress-egress gateway* with 2 network interfaces

## Examples

<!-- TODO @memes - add examples -->

<!-- markdownlint-disable MD033 MD034-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.17 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | >= 0.11.42 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.sli](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.slo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.inside_ce_ce_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.inside_ce_ce_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.outside_ce_ce_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.outside_ce_ce_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| volterra_securemesh_site_v2.site | resource |
| volterra_token.reg | resource |
| [google_compute_subnetwork.inside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_subnetwork.outside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name to apply to the GCP VPC site. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the CE nodes will be created. If blank/null, the nodes will be created in the same<br/>project that contains the outside VPC network. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The email address of the service account which will be used for CE instances. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Provides the Compute Engine subnetworks to use for outside and, optionally,<br/>inside networking of deployed gateway. | <pre>object({<br/>    inside  = string<br/>    outside = string<br/>  })</pre> | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | An optional set of key:value annotations that will be added to generated XC<br/>resources. | `map(string)` | `{}` | no |
| <a name="input_dc_cluster_group"></a> [dc\_cluster\_group](#input\_dc\_cluster\_group) | n/a | <pre>object({<br/>    interface = string<br/>    name      = string<br/>    namespace = string<br/>    tenant    = string<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | An optional description to apply to the GCP VPC Site. If empty, a generated<br/>description will be applied. | `string` | `null` | no |
| <a name="input_forward_proxy_policies"></a> [forward\_proxy\_policies](#input\_forward\_proxy\_policies) | n/a | <pre>list(object({<br/>    name      = string<br/>    namespace = string<br/>    tenant    = string<br/>  }))</pre> | `null` | no |
| <a name="input_gcp_labels"></a> [gcp\_labels](#input\_gcp\_labels) | An optional set of key:value string pairs that will be added on the | `map(string)` | `{}` | no |
| <a name="input_global_networks"></a> [global\_networks](#input\_global\_networks) | n/a | <pre>object({<br/>    inside = object({<br/>      name      = string<br/>      namespace = string<br/>      tenant    = string<br/>    })<br/>    outside = object({<br/>      name      = string<br/>      namespace = string<br/>      tenant    = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The self-link URI for a CE machine image to use as a base for the CE cluster. This can be an official F5 image from<br/>GCP Marketplace, or a customised image. Default is the latest F5 published SMSv2 image at time of commit. | `string` | `"projects/f5-7626-networks-public/global/images/f5xc-ce-9202444-20241230010942"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of key:value string pairs that will be added generated XC<br/>resources. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use for CE nodes; this may be a standard GCE machine type, or a customised VM<br/>('custom-VCPUS-MEM\_IN\_MB'). Default value is 'n2-standard-8'. | `string` | `"n2-standard-8"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Provide custom metadata values to add to each CE instances. | `map(string)` | `{}` | no |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | n/a | <pre>object({<br/>    type = string<br/>    refs = list(object({<br/>      name      = string<br/>      namespace = string<br/>      tenant    = string<br/>  })) })</pre> | `null` | no |
| <a name="input_site_options"></a> [site\_options](#input\_site\_options) | n/a | <pre>object({<br/>    blocked_services = map(object({<br/>      dns                = bool<br/>      ssh                = bool<br/>      web_user_interface = bool<br/>    }))<br/>    log_receiver = object({<br/>      name      = string<br/>      namespace = string<br/>      tenant    = string<br/>    })<br/>    offline_survivability_mode = bool<br/>    perf_mode                  = string<br/>    sm_connection              = string<br/>    ha                         = bool<br/>  })</pre> | <pre>{<br/>  "blocked_services": null,<br/>  "ha": true,<br/>  "log_receiver": null,<br/>  "offline_survivability_mode": false,<br/>  "perf_mode": null,<br/>  "sm_connection": null<br/>}</pre> | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The SSH Public Key that will be installed on CE nodes to allow access.<br/><br/>E.g.<br/>ssh\_key = "ssh-rsa AAAAB3...acw==" | `string` | `null` | no |
| <a name="input_static_routes"></a> [static\_routes](#input\_static\_routes) | n/a | <pre>object({<br/>    outside = object({<br/>      simple = list(string)<br/>      custom = list(object({<br/>        type   = string<br/>        attrs  = list(string)<br/>        labels = map(string)<br/>        interface = object({<br/>          name      = string<br/>          namespace = string<br/>          tenant    = string<br/>        })<br/>        address = string<br/>        subnets = list(string)<br/>      }))<br/>    })<br/>    inside = object({<br/>      # GCP VPC site does not support simple static routes on inside<br/>      # simple = list(string)<br/>      custom = list(object({<br/>        type   = string<br/>        attrs  = list(string)<br/>        labels = map(string)<br/>        interface = object({<br/>          name      = string<br/>          namespace = string<br/>          tenant    = string<br/>        })<br/>        address = string<br/>        subnets = list(string)<br/>      }))<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional network tags which will be added to the CE VMs. | `list(string)` | `[]` | no |
| <a name="input_vm_options"></a> [vm\_options](#input\_vm\_options) | n/a | <pre>object({<br/>    disk_size     = number<br/>    disk_type     = string<br/>    os_version    = string<br/>    sw_version    = string<br/>    public_slo_ip = bool<br/>    public_sli_ip = bool<br/>    nic_type      = string<br/>  })</pre> | <pre>{<br/>  "disk_size": 80,<br/>  "disk_type": "pd-ssd",<br/>  "nic_type": null,<br/>  "os_version": null,<br/>  "public_sli_ip": false,<br/>  "public_slo_ip": false,<br/>  "sw_version": null<br/>}</pre> | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The compute zones where where the CE instances will be deployed. If provided, the CE nodes will be constrained to this<br/>set, if empty the CE nodes will be distributed over all zones available within the outside subnet region.<br/><br/>E.g. to force a single-zone deployment, zones = ["us-west1-a"]. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | A map of CE node names to values |
| <a name="output_smsv2_site_id"></a> [smsv2\_site\_id](#output\_smsv2\_site\_id) | The identifier of the F5 Distributed Cloud SMS v2 site. |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 MD034 -->

[f5 distributed cloud role]: https://registry.terraform.io/modules/memes/f5-distributed-cloud-role/google/latest?tab=readme
[gcp vpc site]: https://docs.cloud.f5.com/docs/how-to/site-management/create-gcp-site
