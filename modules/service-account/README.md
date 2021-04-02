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
| terraform | >= 0.13.0 |
| google | >= 3.58 |
| volterra | >= 0.2.1 |

## Providers

| Name | Version |
|------|---------|
| random | n/a |
| volterra | >= 0.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| role | ../role/ |  |
| sa | terraform-google-modules/service-accounts/google | 4.0.0 |

## Resources

| Name |
|------|
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [volterra_cloud_credentials](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs/resources/cloud_credentials) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gcp\_project\_id | Sets the GCP project id for resource creation. | `string` | n/a | yes |
| annotations | An optional list of annotations to apply to generated Volterra cloud credentials. | `map(string)` | `{}` | no |
| cloud\_credential\_name | The name to assign to the Volterra Cloud Credentials that will contain the GCP<br>service account JSON keyfile. See also `volterra_namespace`. | `string` | `""` | no |
| gcp\_role\_name | The name to assign to the generated custom IAM role; if left blank (default) a<br>semi-random name will be generated. | `string` | `""` | no |
| gcp\_service\_account\_name | The name to assign to the generated service account; if left blank (default) a<br>semi-random name will be generated. | `string` | `""` | no |
| labels | An optional list of labels to apply to generated Volterra cloud credentials. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_credential\_name | The name of the Volterra cloud credential containing the GCP service account<br>credentials file. |
| cloud\_credential\_namespace | The namespace containing the Volterra cloud credential for GCP service account. |
| gcp\_service\_account | The fully-qualified GCP service account that was created. |
| role\_id | The qualified role-id for the custom Volterra role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
