terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.57"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.20"
    }
  }
}

locals {
  labels = merge({}, var.labels)
  annotations = merge({
    "community.f5.com/submodule" = "root"
  }, var.annotations)
}

module "test" {
  source                 = "./../../../"
  name                   = var.name
  description            = var.description
  subnets                = var.subnets
  cloud_credential_name  = var.cloud_credential_name
  labels                 = local.labels
  annotations            = local.annotations
  vm_options             = var.vm_options
  site_options           = var.site_options
  dc_cluster_group       = var.dc_cluster_group
  forward_proxy_policies = var.forward_proxy_policies
  network_policies       = var.network_policies
  global_networks        = var.global_networks
  static_routes          = var.static_routes
}
