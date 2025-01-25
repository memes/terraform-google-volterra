# This module pauses to enable resources to settle between runs.
terraform {
  required_version = ">= 1.2"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12"
    }
  }
}

locals {
  create_duration  = coalesce(var.create_duration, "unspecified") == "unspecified" ? null : var.create_duration
  destroy_duration = coalesce(var.destroy_duration, "unspecified") == "unspecified" ? null : var.destroy_duration
}

resource "null_resource" "alpha" {}

resource "time_sleep" "pause" {
  for_each         = local.create_duration != null || local.destroy_duration != null ? { enabled = true } : {}
  create_duration  = local.create_duration
  destroy_duration = local.destroy_duration
  depends_on = [
    null_resource.alpha,
  ]
}

resource "null_resource" "omega" {
  depends_on = [
    time_sleep.pause,
  ]
}
