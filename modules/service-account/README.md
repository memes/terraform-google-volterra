# Volterra GCP VPC Site Service Account

<!-- spell-checker: ignore volterra -->
This module creates a GCP service account with a binding to a custom IAM role
needed for Volterra GCP VPC Site management, and stores the JSON credentials in
a Volterra Cloud Credential. A one-step module for quickly creating and onboarding
a GCP service account into a Volterra tenant.

## Create a new service account with generated service account and cloud credential names

Terraform will use semi-random names for IAM role, service account, and Volterra
cloud credentials name.

<!-- spell-checker: disable -->
```hcl
module "volterra_sa" {
  source                   = "memes/volterra/google//modules/service-account"
  version                  = "0.2.0"
  gcp_project_id           = "my-gcp-project"
}
```
<!-- spell-checker: enable -->

## Create a new service account with specified names

<!-- spell-checker: disable -->
```hcl
module "volterra_sa" {
  source                         = "memes/volterra/google//modules/service-account"
  version                        = "0.2.0"
  gcp_project_id                 = "my-gcp-project"
  gcp_role_name                  = "my-volterra-role"
  gcp_service_account_name       = "my-volterra-sa"
  volterra_cloud_credential_name = "my-gcp-creds"
}
```
<!-- spell-checker: enable -->

<!-- spell-checker:ignore markdownlint bigip -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.77 |
| <a name="requirement_volterra"></a> [volterra](#requirement\_volterra) | >= 0.8.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_volterra"></a> [volterra](#provider\_volterra) | >= 0.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_role"></a> [role](#module\_role) | ../role/ | n/a |
| <a name="module_sa"></a> [sa](#module\_sa) | terraform-google-modules/service-accounts/google | 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [random_id.sa_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [volterra_cloud_credentials.sa](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/cloud_credentials) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | Sets the GCP project id for resource creation. | `string` | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | An optional list of annotations to apply to generated Volterra cloud credentials. | `map(string)` | `{}` | no |
| <a name="input_cloud_credential_name"></a> [cloud\_credential\_name](#input\_cloud\_credential\_name) | The name to assign to the Volterra Cloud Credentials that will contain the GCP<br>service account JSON keyfile. See also `volterra_namespace`. | `string` | `""` | no |
| <a name="input_gcp_role_name"></a> [gcp\_role\_name](#input\_gcp\_role\_name) | The name to assign to the generated custom IAM role; if left blank (default) a<br>semi-random name will be generated. | `string` | `""` | no |
| <a name="input_gcp_service_account_name"></a> [gcp\_service\_account\_name](#input\_gcp\_service\_account\_name) | The name to assign to the generated service account; if left blank (default) a<br>semi-random name will be generated. | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional list of labels to apply to generated Volterra cloud credentials. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_credential_name"></a> [cloud\_credential\_name](#output\_cloud\_credential\_name) | The name of the Volterra cloud credential containing the GCP service account<br>credentials file. |
| <a name="output_cloud_credential_namespace"></a> [cloud\_credential\_namespace](#output\_cloud\_credential\_namespace) | The namespace containing the Volterra cloud credential for GCP service account. |
| <a name="output_gcp_service_account"></a> [gcp\_service\_account](#output\_gcp\_service\_account) | The fully-qualified GCP service account that was created. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The qualified role-id for the custom Volterra role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
