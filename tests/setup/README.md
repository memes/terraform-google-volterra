# Setup

The Terraform in this folder will be executed before creating resources and can
be used to setup service accounts, service principals, etc, that are used by the
inspec-* verifiers.

## Configuration

Create a local `terraform.tfvars` file that configures the testing constraints.

```hcl
# An optional prefix to apply to resource names
prefix = "my-test"

# The GCP project identifier to use
project_id  = "my-gcp-project"

# The GCP Compute Engine region where the resources will be provisioned
region = "us-west1"

# The F5 XC namespace to use for resources
namespace = "my-ns"

# Optional labels to add to F5 XC resources
labels = {
    "owner" = "tester-name"
}

# Optional kubernetes annotations to add to F5 XC resources
annotations = {
    "example.com/owner" = "tester-name"
}

# Optional labels to add to Google Cloud resources
gcp_labels = {
    "owner" = "tester-name"
}
```

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_f5xc"></a> [f5xc](#requirement\_f5xc) | >= 0.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.17 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | >= 0.11.42 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns"></a> [dns](#module\_dns) | memes/restricted-apis-dns/google | 1.3.0 |
| <a name="module_inside"></a> [inside](#module\_inside) | memes/multi-region-private-network/google | 3.1.0 |
| <a name="module_outside"></a> [outside](#module\_outside) | memes/multi-region-private-network/google | 3.1.0 |
| <a name="module_outside_bastion"></a> [outside\_bastion](#module\_outside\_bastion) | memes/private-bastion/google | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.inside_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.outside_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.test_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_image.xc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image) | resource |
| [google_service_account.xc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [local_file.harness_yml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_privkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_pubkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| volterra_dc_cluster_group.dc_inside | resource |
| volterra_dc_cluster_group.dc_outside | resource |
| volterra_enhanced_firewall_policy.allow_test | resource |
| volterra_forward_proxy_policy.allow_test | resource |
| volterra_virtual_network.inside_global | resource |
| volterra_virtual_network.outside_global | resource |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | n/a | `map(string)` | `{}` | no |
| <a name="input_gcp_labels"></a> [gcp\_labels](#input\_gcp\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `"gvpc"` | no |
| <a name="input_region"></a> [region](#input\_region) | Prefer us-central1 region because it tends to have all machine types available | `string` | `"us-central1"` | no |
| <a name="input_test_cidrs"></a> [test\_cidrs](#input\_test\_cidrs) | n/a | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_annotations"></a> [annotations](#output\_annotations) | n/a |
| <a name="output_bastion"></a> [bastion](#output\_bastion) | n/a |
| <a name="output_custom_ce_image"></a> [custom\_ce\_image](#output\_custom\_ce\_image) | n/a |
| <a name="output_forward_proxy_policy"></a> [forward\_proxy\_policy](#output\_forward\_proxy\_policy) | n/a |
| <a name="output_gcp_labels"></a> [gcp\_labels](#output\_gcp\_labels) | n/a |
| <a name="output_inside_dc_group"></a> [inside\_dc\_group](#output\_inside\_dc\_group) | n/a |
| <a name="output_inside_global"></a> [inside\_global](#output\_inside\_global) | n/a |
| <a name="output_inside_nat_tags"></a> [inside\_nat\_tags](#output\_inside\_nat\_tags) | n/a |
| <a name="output_inside_self_link"></a> [inside\_self\_link](#output\_inside\_self\_link) | n/a |
| <a name="output_labels"></a> [labels](#output\_labels) | n/a |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |
| <a name="output_outside_dc_group"></a> [outside\_dc\_group](#output\_outside\_dc\_group) | n/a |
| <a name="output_outside_global"></a> [outside\_global](#output\_outside\_global) | n/a |
| <a name="output_outside_nat_tags"></a> [outside\_nat\_tags](#output\_outside\_nat\_tags) | n/a |
| <a name="output_outside_self_link"></a> [outside\_self\_link](#output\_outside\_self\_link) | n/a |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The combination of random and user-supplied elements that were used for this test suite run. |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_sa"></a> [sa](#output\_sa) | n/a |
| <a name="output_ssh_privkey_path"></a> [ssh\_privkey\_path](#output\_ssh\_privkey\_path) | n/a |
| <a name="output_ssh_pubkey"></a> [ssh\_pubkey](#output\_ssh\_pubkey) | n/a |
| <a name="output_ssh_pubkey_path"></a> [ssh\_pubkey\_path](#output\_ssh\_pubkey\_path) | n/a |
| <a name="output_subnet_self_links"></a> [subnet\_self\_links](#output\_subnet\_self\_links) | Self-links for the outside and inside VPC networks created for shared test harness. |
| <a name="output_zones"></a> [zones](#output\_zones) | n/a |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
