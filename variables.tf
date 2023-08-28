variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "The name variable must be RFC1035 compliant and between 1 and 63 characters in length."
  }
  description = <<-EOD
  The name to apply to the GCP VPC site.
  EOD
}

variable "description" {
  type        = string
  default     = null
  description = <<-EOD
    An optional description to apply to the GCP VPC Site. If empty, a generated
    description will be applied.
    EOD
}

variable "subnets" {
  type = object({
    inside  = string
    outside = string
  })
  validation {
    condition     = var.subnets == null ? false : can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", var.subnets.inside)) && can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", var.subnets.outside))
    error_message = "The subnet value must have a valid self_link URI, and non-empty pods and services names, and a valid master CIDR."
  }
  description = <<-EOD
  Provides the Compute Engine subnetworks to use for outside and, optionally,
  inside networking of deployed gateway.
  EOD
}

variable "cloud_credential_name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.cloud_credential_name))
    error_message = "The cloud_credential_name variable must be RFC1035 compliant and between 1 and 63 characters in length."
  }
  description = <<-EOD
  The name of an existing Cloud Credential to use when generating this site.
  EOD
}

variable "labels" {
  type = map(string)
  validation {
    # XC labels keys must have keys that match [prefix/]name, where name is a
    # valid DNS label, and prefix is an optional valid DNS domain with <= 253
    # characters.
    condition     = var.labels == null ? true : length(compact([for k, v in var.labels : can(regex("^(?:(?:[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\\.)+[a-zA-Z]{2,63}/)?[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", k)) && can(regex("^(?:[^/]{1,253}/)?[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", k)) && can(regex("^(?:[A-Za-z0-9][-A-Za-z0-9_.]{0,126})?[A-Za-z0-9]$", v)) ? "x" : ""])) == length(keys(var.labels))
    error_message = "Each label key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional set of key:value string pairs that will be added generated XC
  resources.
  EOD
}

variable "annotations" {
  type = map(string)
  validation {
    # Kubernetes annotations must have keys are [prefix/]name, where name is a
    # valid DNS label, and prefix is a valid DNS domain with <= 253 characters.
    # Values are not restricted; total combined of all keys and values <= 256Kb
    # which is not a feasible Terraform validation rule.
    condition     = var.annotations == null ? true : length(compact([for k, v in var.annotations : can(regex("^(?:(?:[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\\.)+[a-zA-Z]{2,63}/)?[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", k)) && can(regex("^(?:[^/]{1,253}/)?[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", k)) ? "x" : ""])) == length(keys(var.annotations))
    error_message = "Each annotation key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional set of key:value annotations that will be added to generated XC
  resources.
  EOD
}

variable "gcp_labels" {
  type = map(string)
  validation {
    # GCP resource labels must be lowercase alphanumeric, underscore or hyphen,
    # and the key must be <= 63 characters in length
    condition     = length(compact([for k, v in var.gcp_labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v)) ? "x" : ""])) == length(keys(var.gcp_labels))
    error_message = "Each label key:value pair must match GCP requirements."
  }
  default     = {}
  description = <<-EOD
  An optional set of key:value string pairs that will be added on the
  EOD
}

variable "vm_options" {
  type = object({
    disk_size     = number
    instance_type = string
    nodes_per_az  = number
    os_version    = string
    ssh_key       = string
    sw_version    = string
    zones         = list(string)
  })
  default = {
    disk_size     = 80
    instance_type = "n2-standard-8"
    nodes_per_az  = 0
    os_version    = null
    ssh_key       = null
    sw_version    = null
    zones         = null
  }
}

variable "site_options" {
  type = object({
    blocked_services = map(object({
      dns                = bool
      ssh                = bool
      web_user_interface = bool
    }))
    log_receiver = object({
      name      = string
      namespace = string
      tenant    = string
    })
    offline_survivability_mode = bool
    perf_mode                  = string
    sm_connection              = string
  })
  default = {
    blocked_services           = null
    log_receiver               = null
    offline_survivability_mode = false
    perf_mode                  = null
    sm_connection              = null
  }
}

variable "dc_cluster_group" {
  type = object({
    interface = string
    name      = string
    namespace = string
    tenant    = string
  })
  default = null
}

variable "forward_proxy_policies" {
  type = list(object({
    name      = string
    namespace = string
    tenant    = string
  }))
  validation {
    condition     = try(length(var.forward_proxy_policies), 0) == 0 ? true : alltrue([for ref in var.forward_proxy_policies : can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.name)) && can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.namespace)) && (ref.tenant == null || can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.tenant)))])
    error_message = "Each forward_proxy_policies entry must have a valid reference with name and namespace, and an optional tenant."
  }
  default = null
}

variable "network_policies" {
  type = object({
    type = string
    refs = list(object({
      name      = string
      namespace = string
      tenant    = string
  })) })
  validation {
    condition     = try(length(var.network_policies), 0) == 0 ? true : contains(["enhanced_firewall", "network"], coalesce(try(var.network_policies.type, "unspecified"), "unspecified") && alltrue([for ref in var.network_policies : can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.name)) && can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.namespace)) && (ref.tenant == null || can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", ref.tenant)))]))
    error_message = "Each network_policies entry must have a valid `type` and a valid reference."
  }
  default = null
}

variable "global_networks" {
  type = object({
    inside = object({
      name      = string
      namespace = string
      tenant    = string
    })
    outside = object({
      name      = string
      namespace = string
      tenant    = string
    })
  })
  default = null
}

variable "static_routes" {
  type = object({
    outside = object({
      simple = list(string)
      custom = list(object({
        type   = string
        attrs  = list(string)
        labels = map(string)
        interface = object({
          name      = string
          namespace = string
          tenant    = string
        })
        address = string
        subnets = list(string)
      }))
    })
    inside = object({
      # GCP VPC site does not support simple static routes on inside
      # simple = list(string)
      custom = list(object({
        type   = string
        attrs  = list(string)
        labels = map(string)
        interface = object({
          name      = string
          namespace = string
          tenant    = string
        })
        address = string
        subnets = list(string)
      }))
    })
  })
  default = null
}
