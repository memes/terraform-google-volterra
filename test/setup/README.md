# Setup

The Terraform in this folder will be executed before creating resources and can
be used to setup service accounts, service principals, etc, that are used by the
inspec-* verifiers.

## Configuration

Create a local `terraform.tfvars` file that configures the testing project
constraints.

```hcl
# The GCP project identifier to use
project_id  = "my-gcp-project"

# The single Compute Engine region where the resources will be created
region = "us-west1"

# Optional labels to add to resources
labels = {
    "owner" = "tester-name"
}

# Optional: Override default Google Container Registry location
gcr_location = "EU"

```

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.22 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | >= 0.11.31 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inside"></a> [inside](#module\_inside) | memes/multi-region-private-network/google | 2.0.0 |
| <a name="module_outside"></a> [outside](#module\_outside) | memes/multi-region-private-network/google | 2.0.0 |
| <a name="module_xc_role"></a> [xc\_role](#module\_xc\_role) | memes/f5-distributed-cloud-role/google | 1.0.7 |

## Resources

| Name | Type |
|------|------|
| [f5xc_blindfold.xc](https://registry.terraform.io/providers/memes/f5xc/latest/docs/resources/blindfold) | resource |
| [google_compute_firewall.test_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_project_iam_member.xc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.xc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.xc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [local_file.harness_yml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_privkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_pubkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [volterra_cloud_credentials.xc](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/cloud_credentials) | resource |
| [volterra_dc_cluster_group.dc_inside](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/dc_cluster_group) | resource |
| [volterra_dc_cluster_group.dc_outside](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/dc_cluster_group) | resource |
| [volterra_enhanced_firewall_policy.allow_test](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/enhanced_firewall_policy) | resource |
| [volterra_forward_proxy_policy.allow_test](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/forward_proxy_policy) | resource |
| [volterra_virtual_network.inside_global](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/virtual_network) | resource |
| [volterra_virtual_network.outside_global](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/virtual_network) | resource |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | n/a | `map(string)` | `{}` | no |
| <a name="input_gcp_labels"></a> [gcp\_labels](#input\_gcp\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `"gvpc"` | no |
| <a name="input_test_cidrs"></a> [test\_cidrs](#input\_test\_cidrs) | n/a | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_annotations"></a> [annotations](#output\_annotations) | n/a |
| <a name="output_cloud_credential_name"></a> [cloud\_credential\_name](#output\_cloud\_credential\_name) | n/a |
| <a name="output_forward_proxy_policy"></a> [forward\_proxy\_policy](#output\_forward\_proxy\_policy) | n/a |
| <a name="output_gcp_labels"></a> [gcp\_labels](#output\_gcp\_labels) | n/a |
| <a name="output_harness_yml"></a> [harness\_yml](#output\_harness\_yml) | n/a |
| <a name="output_inside_dc_group"></a> [inside\_dc\_group](#output\_inside\_dc\_group) | n/a |
| <a name="output_inside_global"></a> [inside\_global](#output\_inside\_global) | n/a |
| <a name="output_inside_self_link"></a> [inside\_self\_link](#output\_inside\_self\_link) | n/a |
| <a name="output_labels"></a> [labels](#output\_labels) | n/a |
| <a name="output_outside_dc_group"></a> [outside\_dc\_group](#output\_outside\_dc\_group) | n/a |
| <a name="output_outside_global"></a> [outside\_global](#output\_outside\_global) | n/a |
| <a name="output_outside_self_link"></a> [outside\_self\_link](#output\_outside\_self\_link) | n/a |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | n/a |
| <a name="output_ssh_privkey_path"></a> [ssh\_privkey\_path](#output\_ssh\_privkey\_path) | n/a |
| <a name="output_ssh_pubkey"></a> [ssh\_pubkey](#output\_ssh\_pubkey) | n/a |
| <a name="output_ssh_pubkey_path"></a> [ssh\_pubkey\_path](#output\_ssh\_pubkey\_path) | n/a |
| <a name="output_zones"></a> [zones](#output\_zones) | n/a |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
