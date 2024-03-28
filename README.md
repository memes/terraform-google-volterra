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

### Enable standard overrides

|Item|Managed by module|Description|
|----|-----------------|-----------|
|Override googleapis.com|&check;|Always directed to `restricted.googleapis.com`|
|Override gcr.io|&check;|Default `overrides` value will direct to `restricted.googleapis.com`|
|Override pkg.dev|&check;|Default `overrides` value will direct to `restricted.googleapis.com`|
|Added to VPC network|&check;|Zones will be added as Private Cloud DNS to any VPC network provided in `network_self_links`|
|Route to private endpoints||Must be managed per-VPC|

```hcl
module "restricted_apis" {
    source  = "memes/restricted-apis-dns/google"
    version = "1.2.0"
    project_id = "my-project-id"
    network_self_links = [
        "projects/my-project-id/globals/network/my-network",
    ]
}
```

### Disable restricted override for Container Registry and Artifact Registry

|Item|Managed by module|Description|
|----|-----------------|-----------|
|Override googleapis.com|&check;|Always directed to `restricted.googleapis.com`|
|Override gcr.io||Setting `overrides` to []|
|Override pkg.dev||Setting `overrides` to []|
|Added to VPC network|&check;|Zones will be added as Private Cloud DNS to any VPC network provided in `network_self_links`|
|Route to private endpoints||Must be managed per-VPC|

```hcl
module "restricted_apis" {
    source  = "memes/restricted-apis-dns/google"
    version = "1.2.0"
    project_id = "my-project-id"
    overrides = []
    network_self_links = [
        "projects/my-project-id/globals/network/my-network",
    ]
}
```

<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->

[f5 distributed cloud role]: https://registry.terraform.io/modules/memes/f5-distributed-cloud-role/google/latest?tab=readme
[gcp vpc site]: https://docs.cloud.f5.com/docs/how-to/site-management/create-gcp-site
