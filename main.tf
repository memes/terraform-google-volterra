terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.17"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
    volterra = {
      source  = "registry.terraform.io/volterraedge/volterra"
      version = ">= 0.11.42"
    }
  }
}

data "google_compute_subnetwork" "outside" {
  self_link = var.subnets.outside
}

data "google_compute_subnetwork" "inside" {
  for_each  = coalesce(var.subnets.inside, "unspecified") == "unspecified" ? {} : { sli = var.subnets.inside }
  self_link = each.value
}

data "google_compute_zones" "zones" {
  project = coalesce(var.project_id, data.google_compute_subnetwork.outside.project)
  region  = data.google_compute_subnetwork.outside.region
  status  = "UP"
}

locals {
  // For HA launch 3 nodes named with numerical suffixes; non-HA will launch a single node
  ce_names = try(var.site_options.ha, true) ? formatlist("%s-%02d", var.name, range(0, 3)) : [var.name]
}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.zones.names
  keepers = {
    project_id = var.project_id
    outside    = var.subnets.outside
  }
}

resource "volterra_securemesh_site_v2" "site" {
  name        = var.name
  namespace   = "system"
  description = coalesce(var.description, "SMSv2 site for GCP")
  annotations = var.annotations
  labels      = var.labels

  dynamic "admin_user_credentials" {
    for_each = coalesce(try(trimspace(var.ssh_key), "unspecified"), "unspecified") != "unspecified" ? { creds = { ssh_key = trimspace(var.ssh_key) } } : {}
    content {
      # admin_password {
      # }
      ssh_key = admin_user_credentials.value.ssh_key
    }
  }

  block_all_services = try(length(var.site_options.blocked_services), 0) == 0 ? true : null
  dynamic "blocked_services" {
    for_each = try(length(var.site_options.blocked_services), 0) != 0 ? var.site_options.blocked_services : {}
    content {
      blocked_sevice {
        dns          = blocked_services.value.dns
        network_type = blocked_services.key
      }
      blocked_sevice {
        ssh          = blocked_services.value.ssh
        network_type = blocked_services.key
      }
      blocked_sevice {
        web_user_interface = blocked_services.value.web_user_interface
        network_type       = blocked_services.key
      }
    }
  }

  disable_ha = length(local.ce_names) == 1 ? true : null
  enable_ha  = length(local.ce_names) == 1 ? null : true

  dns_ntp_config {
    custom_dns {
      dns_servers = [
        "169.254.169.254",
      ]
    }
    custom_ntp {
      ntp_servers = [
        "169.254.169.254",
      ]
    }
  }

  gcp {
    not_managed {}
  }

  f5_proxy = true

  dynamic "log_receiver" {
    for_each = try(length(var.site_options.log_receiver), 0) != 0 ? { params = var.site_options.log_receiver } : {}
    content {
      name      = log_receiver.value.name
      namespace = log_receiver.value.namespace
      tenant    = log_receiver.value.tenant
    }
  }
  logs_streaming_disabled = try(length(var.site_options.log_receiver), 0) == 0

  dynamic "offline_survivability_mode" {
    for_each = try(var.site_options.offline_survivability_mode, false) ? { enable = true } : {}
    content {
      enable_offline_survivability_mode = true
    }
  }

  dynamic "offline_survivability_mode" {
    for_each = try(var.site_options.offline_survivability_mode, false) ? {} : { disable = true }
    content {
      no_offline_survivability_mode = true
    }
  }

  disable           = false
  no_network_policy = true
  no_forward_proxy  = true
  software_settings {
    sw {
      default_sw_version = true
    }
    os {
      default_os_version = true
    }
  }
  upgrade_settings {
    kubernetes_upgrade_drain {
      enable_upgrade_drain {
        drain_node_timeout               = 300
        drain_max_unavailable_node_count = 1
      }
    }
  }
  performance_enhancement_mode {
    perf_mode_l7_enhanced = true
  }
  tunnel_dead_timeout = 0
  load_balancing {
    vip_vrrp_mode = "VIP_VRRP_DISABLE"
  }
  no_s2s_connectivity_slo = true
  no_s2s_connectivity_sli = true
  local_vrf {
    default_config     = true
    default_sli_config = true
  }
  tunnel_type = "SITE_TO_SITE_TUNNEL_IPSEC_OR_SSL"
  re_select {
    geo_proximity = true
  }
  proactive_monitoring {
    proactive_monitoring_enable = true
  }

  lifecycle {
    # Annotations and labels are often changed outside of provisioning, and the gcp field will be updated as the nodes
    # join.
    ignore_changes = [
      annotations,
      labels,
      gcp[0].not_managed,
    ]
  }
}

resource "volterra_token" "reg" {
  for_each    = { for name in local.ce_names : name => {} }
  name        = each.key
  namespace   = "system"
  description = coalesce(var.description, "Registration token for GCP site")
  type        = 1
  site_name   = volterra_securemesh_site_v2.site.name
  annotations = var.annotations
  labels      = var.labels
}

resource "google_compute_address" "slo" {
  for_each     = { for name in local.ce_names : name => {} }
  project      = var.project_id
  name         = format("%s-slo", each.key)
  description  = format("Reserved for SLO on %s", each.key)
  subnetwork   = data.google_compute_subnetwork.outside.self_link
  region       = data.google_compute_subnetwork.outside.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  labels       = var.gcp_labels
}

resource "google_compute_address" "sli" {
  for_each     = length(data.google_compute_subnetwork.inside) == 0 ? {} : { for name in local.ce_names : name => {} }
  project      = var.project_id
  name         = format("%s-sli", each.key)
  description  = format("Reserved for SLI on %s", each.key)
  subnetwork   = data.google_compute_subnetwork.inside["sli"].self_link
  region       = data.google_compute_subnetwork.inside["sli"].region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  labels       = var.gcp_labels
}

resource "google_compute_firewall" "outside_ce_ce_ingress" {
  for_each           = length(google_compute_address.slo) > 1 ? { enable = true } : {}
  project            = var.project_id
  name               = format("%s-slo-ce-ce-ingress", var.name)
  network            = data.google_compute_subnetwork.outside.network
  description        = "Allow ingress from CE to other CE nodes on SLO"
  direction          = "INGRESS"
  priority           = 900
  destination_ranges = [for slo in google_compute_address.slo : slo.address]
  source_ranges      = [for slo in google_compute_address.slo : slo.address]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "outside_ce_ce_egress" {
  for_each           = length(google_compute_address.slo) > 1 ? { enable = true } : {}
  project            = var.project_id
  name               = format("%s-slo-ce-ce-egress", var.name)
  network            = data.google_compute_subnetwork.outside.network
  description        = "Allow egress from CE to other CE nodes on SLO"
  direction          = "EGRESS"
  priority           = 900
  destination_ranges = [for slo in google_compute_address.slo : slo.address]
  source_ranges      = [for slo in google_compute_address.slo : slo.address]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "inside_ce_ce_ingress" {
  for_each           = length(google_compute_address.sli) > 1 ? { enable = true } : {}
  project            = var.project_id
  name               = format("%s-sli-ce-ce-ingress", var.name)
  network            = data.google_compute_subnetwork.inside["sli"].network
  description        = "Allow ingress from CE to other CE nodes on SLI"
  direction          = "INGRESS"
  priority           = 900
  destination_ranges = [for k, v in google_compute_address.sli : v.address]
  source_ranges      = [for k, v in google_compute_address.sli : v.address]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "inside_ce_ce_egress" {
  for_each           = length(google_compute_address.sli) > 1 ? { enable = true } : {}
  project            = var.project_id
  name               = format("%s-sli-ce-ce-egress", var.name)
  network            = data.google_compute_subnetwork.inside["sli"].network
  description        = "Allow egress from CE to other CE nodes on SLI"
  direction          = "EGRESS"
  priority           = 900
  destination_ranges = [for k, v in google_compute_address.sli : v.address]
  source_ranges      = [for k, v in google_compute_address.sli : v.address]
  allow {
    protocol = "all"
  }
}

resource "google_compute_instance" "node" {
  for_each = { for i, name in local.ce_names : name => {
    zone   = try(element(var.zones, i), element(random_shuffle.zones.result, i))
    token  = trimspace(volterra_token.reg[name].id)
    slo_ip = google_compute_address.slo[name].address
    sli_ip = try(google_compute_address.sli[name].address, null)
  } }

  project = coalesce(try(var.vm_options.project_id, ""), data.google_compute_subnetwork.outside.project)
  name    = each.key
  zone    = each.value.zone
  labels  = var.gcp_labels
  metadata = merge(
    {
      VmDnsSetting = "ZonePreferred",
      user-data    = <<-EOCI
      #cloud-config
      ---
      write_files:
        - path: /etc/vpm/user_data
          permissions: '0644'
          owner: 'root:root'
          content: |
            token: ${each.value.token}
      EOCI
    },
    var.metadata
  )

  # Scheduling options
  machine_type = coalesce(var.machine_type, "n2-standard-8")
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  scheduling {
    automatic_restart = true
    preemptible       = false
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      type  = try(var.vm_options.disk_type, "pd-ssd")
      size  = try(var.vm_options.disk_size, 80)
      image = var.image
    }

  }

  # Networking properties
  tags           = var.tags
  can_ip_forward = true

  # SLO is always nic0
  network_interface {
    subnetwork = var.subnets.outside
    network_ip = each.value.slo_ip
    nic_type   = coalesce(try(var.vm_options.nic_type, "VIRTIO_NET"), "VIRTIO_NET")
    dynamic "access_config" {
      for_each = try(var.vm_options.public_slo_ip, false) ? { public = true } : {}
      content {
        # TODO @memes - support explicit public ip assignment?
        nat_ip = null
      }
    }
  }

  # If an explicit SLI is requested it should be nic1
  dynamic "network_interface" {
    for_each = each.value.sli_ip == null ? {} : { sli = {} }
    content {
      subnetwork = data.google_compute_subnetwork.inside["sli"].self_link
      network_ip = each.value.sli_ip
      nic_type   = coalesce(try(var.vm_options.nic_type, "VIRTIO_NET"), "VIRTIO_NET")
      dynamic "access_config" {
        for_each = try(var.vm_options.public_sli_ip, false) ? { public = true } : {}
        content {
          # TODO @memes - support explicit public ip assignment?
          nat_ip = null
        }
      }
    }
  }

  # TODO @memes - support other interfaces in the future?
  dynamic "network_interface" {
    for_each = try(var.subnets.other, null) == null ? {} : {}
    content {
      subnetwork = network_interface.value
      # TODO @memes - support explicit private IP assignment?
      network_ip = null
      nic_type   = coalesce(try(var.vm_options.nic_type, "VIRTIO_NET"), "VIRTIO_NET")
      dynamic "access_config" {
        for_each = false ? { public = true } : {}
        content {
          # TODO @memes - support explicit public ip assignment?
          nat_ip = null
        }
      }
    }
  }
}
