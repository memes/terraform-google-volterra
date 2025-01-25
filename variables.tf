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

# variable "namespace" {
#   type = string
#   validation {
#     condition     = can(regex("^[a-zA-Z0-9]?[a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.namespace))
#     error_message = "Namespace is required and must be valid RFC1035."
#   }
#   description = <<-EOD
#   The F5 Distributed Cloud namespace to use for resources that do not have a fixed namespace requirement.
#   EOD
# }

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
    condition     = var.subnets == null ? false : (var.subnets.inside == null || var.subnets.inside == "" || can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", var.subnets.inside))) && can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", var.subnets.outside))
    error_message = "The subnet value must have a valid self_link URI, and non-empty pods and services names, and a valid master CIDR."
  }
  description = <<-EOD
  Provides the Compute Engine subnetworks to use for outside and, optionally,
  inside networking of deployed gateway.
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
    disk_type     = string
    os_version    = string
    sw_version    = string
    public_slo_ip = bool
    public_sli_ip = bool
    nic_type      = string
  })
  nullable = false
  validation {
    condition     = var.vm_options.disk_size > 45 && floor(var.vm_options.disk_size) == var.vm_options.disk_size && contains(["hyperdisk-balanced", "pd-balanced", "pd-ssd", "pd-standard"], var.vm_options.disk_type)
    error_message = "The vm_options must contain a valid integer disk_size >= 45, and disk_type must be one of 'pd-balanced', 'pd-ssd', or 'pd-standard'."
  }
  default = {
    disk_size     = 80
    disk_type     = "pd-ssd"
    os_version    = null
    sw_version    = null
    public_slo_ip = false
    public_sli_ip = false
    nic_type      = null
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
    ha                         = bool
  })
  default = {
    blocked_services           = null
    log_receiver               = null
    offline_survivability_mode = false
    perf_mode                  = null
    sm_connection              = null
    ha                         = true
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

variable "ssh_key" {
  type        = string
  nullable    = true
  default     = null
  description = <<-EOD
  The SSH Public Key that will be installed on CE nodes to allow access.

  E.g.
  ssh_key = "ssh-rsa AAAAB3...acw=="
  EOD
}

variable "project_id" {
  type = string
  validation {
    condition     = var.project_id == null ? true : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
  The GCP project identifier where the CE nodes will be created. If blank/null, the nodes will be created in the same
  project that contains the outside VPC network.
  EOD
}

variable "zones" {
  type     = list(string)
  nullable = true
  validation {
    condition     = var.zones == null ? true : alltrue([for zone in var.zones : can(regex("^[a-z]{2,20}-[a-z]{4,20}[0-9]-[a-z]$", zone))])
    error_message = "Zones must be null or each zone must be a valid GCE zone name."
  }
  default     = []
  description = <<-EOD
The compute zones where where the CE instances will be deployed. If provided, the CE nodes will be constrained to this
set, if empty the CE nodes will be distributed over all zones available within the outside subnet region.

E.g. to force a single-zone deployment, zones = ["us-west1-a"].
EOD
}

variable "machine_type" {
  type        = string
  default     = "n2-standard-8"
  description = <<-EOD
  The machine type to use for CE nodes; this may be a standard GCE machine type, or a customised VM
  ('custom-VCPUS-MEM_IN_MB'). Default value is 'n2-standard-8'.
  EOD
}

variable "image" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z][a-z0-9-]{0,61}[a-z0-9]", var.image))
    error_message = "The image variable must be a fully-qualified URI."
  }
  default     = "projects/f5-7626-networks-public/global/images/f5xc-ce-9202444-20241230010942"
  description = <<-EOD
  The self-link URI for a CE machine image to use as a base for the CE cluster. This can be an official F5 image from
  GCP Marketplace, or a customised image. Default is the latest F5 published SMSv2 image at time of commit.
  EOD
}

variable "service_account" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^(?:[a-z][a-z0-9-]{4,28}[a-z0-9]@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam|[0-9]+-compute@developer)\\.gserviceaccount\\.com$", var.service_account))
    error_message = "The service_account variable must be a valid GCP service account email address."
  }
  description = <<-EOD
The email address of the service account which will be used for CE instances.
EOD
}

variable "metadata" {
  description = "Provide custom metadata values to add to each CE instances."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "tags" {
  type = list(string)
  validation {
    # GCP tags must be RFC1035 compliant
    condition     = var.tags == null ? true : alltrue([for tag in var.tags : can(regex("^[a-z][a-z0-9_-]{0,62}$", tag))])
    error_message = "Each tag must be RFC1035 compliant expectations."
  }
  default     = []
  description = "Optional network tags which will be added to the CE VMs."
}
