# This module pauses to enable resources to settle between runs.
terraform {
  required_version = ">= 1.2"
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12"
    }
  }
}

resource "null_resource" "alpha" {}

resource "time_sleep" "pause" {
  create_duration  = coalesce(var.create_duration, "10s")
  destroy_duration = coalesce(var.destroy_duration, "10s")
  depends_on = [
    null_resource.alpha,
  ]
}

resource "null_resource" "omega" {
  depends_on = [
    time_sleep.pause,
  ]
}
