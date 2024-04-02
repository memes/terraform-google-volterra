variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "subnets" {
  type = object({
    inside  = string
    outside = string
  })
}

variable "cloud_credential_name" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "vm_options" {
  type = object({
    disk_size     = number
    instance_type = string
    os_version    = string
    sw_version    = string
    zones         = list(string)
  })
  default = {
    disk_size     = 80
    instance_type = "n2-standard-8"
    os_version    = null
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
  nullable    = false
  description = <<-EOD
  The SSH Public Key that will be installed on CE nodes to allow access.

  E.g.
  ssh_key = "ssh-rsa AAAAB3...acw=="
  EOD
}
