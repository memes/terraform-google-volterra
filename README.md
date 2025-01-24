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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.22 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.11 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | >= 0.11.31 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_regions"></a> [regions](#module\_regions) | memes/region-detail/google | 1.1.6 |

## Resources

| Name | Type |
|------|------|
| [time_sleep.pause_before_action](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [volterra_gcp_vpc_site.site](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/gcp_vpc_site) | resource |
| [volterra_tf_params_action.apply](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/tf_params_action) | resource |
| [volterra_tf_params_action.plan](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/tf_params_action) | resource |
| [google_compute_subnetwork.inside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_subnetwork.outside](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_credential_name"></a> [cloud\_credential\_name](#input\_cloud\_credential\_name) | The name of an existing Cloud Credential to use when generating this site. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to apply to the GCP VPC site. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The SSH Public Key that will be installed on CE nodes to allow access.<br><br>E.g.<br>ssh\_key = "ssh-rsa AAAAB3...acw==" | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Provides the Compute Engine subnetworks to use for outside and, optionally,<br>inside networking of deployed gateway. | <pre>object({<br>    inside  = string<br>    outside = string<br>  })</pre> | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | An optional set of key:value annotations that will be added to generated XC<br>resources. | `map(string)` | `{}` | no |
| <a name="input_dc_cluster_group"></a> [dc\_cluster\_group](#input\_dc\_cluster\_group) | n/a | <pre>object({<br>    interface = string<br>    name      = string<br>    namespace = string<br>    tenant    = string<br>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | An optional description to apply to the GCP VPC Site. If empty, a generated<br>description will be applied. | `string` | `null` | no |
| <a name="input_forward_proxy_policies"></a> [forward\_proxy\_policies](#input\_forward\_proxy\_policies) | n/a | <pre>list(object({<br>    name      = string<br>    namespace = string<br>    tenant    = string<br>  }))</pre> | `null` | no |
| <a name="input_gcp_labels"></a> [gcp\_labels](#input\_gcp\_labels) | An optional set of key:value string pairs that will be added on the | `map(string)` | `{}` | no |
| <a name="input_global_networks"></a> [global\_networks](#input\_global\_networks) | n/a | <pre>object({<br>    inside = object({<br>      name      = string<br>      namespace = string<br>      tenant    = string<br>    })<br>    outside = object({<br>      name      = string<br>      namespace = string<br>      tenant    = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of key:value string pairs that will be added generated XC<br>resources. | `map(string)` | `{}` | no |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | n/a | <pre>object({<br>    type = string<br>    refs = list(object({<br>      name      = string<br>      namespace = string<br>      tenant    = string<br>  })) })</pre> | `null` | no |
| <a name="input_site_options"></a> [site\_options](#input\_site\_options) | n/a | <pre>object({<br>    blocked_services = map(object({<br>      dns                = bool<br>      ssh                = bool<br>      web_user_interface = bool<br>    }))<br>    log_receiver = object({<br>      name      = string<br>      namespace = string<br>      tenant    = string<br>    })<br>    offline_survivability_mode = bool<br>    perf_mode                  = string<br>    sm_connection              = string<br>  })</pre> | <pre>{<br>  "blocked_services": null,<br>  "log_receiver": null,<br>  "offline_survivability_mode": false,<br>  "perf_mode": null,<br>  "sm_connection": null<br>}</pre> | no |
| <a name="input_static_routes"></a> [static\_routes](#input\_static\_routes) | n/a | <pre>object({<br>    outside = object({<br>      simple = list(string)<br>      custom = list(object({<br>        type   = string<br>        attrs  = list(string)<br>        labels = map(string)<br>        interface = object({<br>          name      = string<br>          namespace = string<br>          tenant    = string<br>        })<br>        address = string<br>        subnets = list(string)<br>      }))<br>    })<br>    inside = object({<br>      # GCP VPC site does not support simple static routes on inside<br>      # simple = list(string)<br>      custom = list(object({<br>        type   = string<br>        attrs  = list(string)<br>        labels = map(string)<br>        interface = object({<br>          name      = string<br>          namespace = string<br>          tenant    = string<br>        })<br>        address = string<br>        subnets = list(string)<br>      }))<br>    })<br>  })</pre> | `null` | no |
| <a name="input_vm_options"></a> [vm\_options](#input\_vm\_options) | n/a | <pre>object({<br>    disk_size     = number<br>    instance_type = string<br>    os_version    = string<br>    sw_version    = string<br>    zones         = list(string)<br>  })</pre> | <pre>{<br>  "disk_size": 80,<br>  "instance_type": "n2-standard-8",<br>  "os_version": null,<br>  "sw_version": null,<br>  "zones": null<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->

[f5 distributed cloud role]: https://registry.terraform.io/modules/memes/f5-distributed-cloud-role/google/latest?tab=readme
[gcp vpc site]: https://docs.cloud.f5.com/docs/how-to/site-management/create-gcp-site
