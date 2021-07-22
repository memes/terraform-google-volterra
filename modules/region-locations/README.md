# GCP region locations

<!-- spell-checker: ignore volterra -->
This module takes no inputs and returns a single map of GCP compute regions to
an approximate latitude and longitude, to assist Volterra in routing traffic
efficiently.

## Get the map and use
<!-- spell-checker: disable -->
```hcl
module "locations" {
  source    = "memes/volterra/google//modules/region-locations"
  version   = "0.3.0"
}

resource "volterra_gcp_vpc_site" "site" {
  ...
  gcp_region = "us-central1"
  # Add coordinates from locations module lookup
  coordinates {
    latitude = module.locations.lookup["us-central1"].latitude
    longitude = module.locations.lookup["us-central1"].longitude
  }
  ...
}
```
<!-- spell-checker: enable -->

## Handling a new region that doesn't have a lat/long defined

<!-- spell-checker: disable -->
```hcl
module "locations" {
  source    = "memes/volterra/google//modules/region-locations"
  version   = "0.3.0"
}

resource "volterra_gcp_vpc_site" "site" {
  ...
  gcp_region = "us-central1"
  # Add coordinates from locations module lookup, if the region is known
  dynamic "coordinates" {
    for_each = {for k,v in lookup(module.compute_locations.lookup, "new-region-1", {}): k => v }
    content {
      latitude = coordinates.latitude
      longitude = coordinates.longitude
    }
  }
  ...
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

## Providers

No provider.

## Modules

No Modules.

## Resources

No resources.

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| lookup | A map of GCP compute region to a coordinate object with latitude and longitude<br>fields. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
