# Volterra GCP VPC Site Role

<!-- spell-checker: ignore volterra -->
This module creates a custom role that can be granted to a service account that
will be used to manage Volterra GCP VPC Sites.

## Create the custom role in a project, but do not explicitly assign membership
<!-- spell-checker: disable -->
```hcl
module "volterra_role" {
  source    = "memes/volterra/google//modules/role"
  version   = "0.2.0"
  target_id = "my-project-id"
}
```
<!-- spell-checker: enable -->

## Create the custom role for entire org, but do not explicitly assign membership

<!-- spell-checker: disable -->
```hcl
module "volterra_role" {
  source      = "memes/volterra/google//modules/role"
  version     = "0.2.0"
  target_type = "org"
  target_id   = "my-org-id"
}
```
<!-- spell-checker: enable -->

## Create the custom role in the project with a fixed id, and assign to a Volterra service account

<!-- spell-checker: disable -->
```hcl
module "volterra_role" {
  source    = "memes/volterra/google//modules/role"
  version   = "0.2.0"
  id        = "my_volterra_role"
  target_id = "my-project-id"
  members   = ["serviceAccount:volterra@my-project-id.iam.gserviceaccount.com"]
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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_role"></a> [role](#module\_role) | terraform-google-modules/iam/google//modules/custom_role_iam | 7.2.0 |

## Resources

| Name | Type |
|------|------|
| [random_id.role_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | Sets the target for Volterra role creation; must be either an organization ID<br>(target\_type = 'org'), or project ID (target\_type = 'project'). | `string` | n/a | yes |
| <a name="input_id"></a> [id](#input\_id) | An identifier to use for the new role; default is an empty string which will<br>generate a unique identifier. If a value is provided, it must be unique at the<br>organization or project level depending on value of target\_type respectively.<br>E.g. multiple projects can all have a 'volterra\_vpc' role defined in each project,<br>but an organization level role must be uniquely named. | `string` | `""` | no |
| <a name="input_members"></a> [members](#input\_members) | An optional list of accounts that will be assigned the custom role. Default is an empty list, meaning that the assignment of the role to accounts will happen<br>elsewhere. | `list(string)` | `[]` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Determines if the Volterra role is to be created for the whole organization ('org')<br>or at a 'project' level. Default is 'project'. | `string` | `"project"` | no |
| <a name="input_title"></a> [title](#input\_title) | The human-readable title to assign to the custom Volterra role. Default is<br>'Custom Volterra VPC role'. | `string` | `"Custom Volterra VPC role"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_qualified_role_id"></a> [qualified\_role\_id](#output\_qualified\_role\_id) | The qualified role-id for the custom Volterra role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
