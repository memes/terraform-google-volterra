terraform {
  required_version = ">= 1.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.57"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.20"
    }
  }
}

data "google_compute_subnetwork" "outside" {
  self_link = var.subnets.outside
}

data "google_compute_subnetwork" "inside" {
  self_link = var.subnets.inside
}

data "google_compute_zones" "zones" {
  project = data.google_compute_subnetwork.outside.project
  region  = data.google_compute_subnetwork.outside.region
  status  = "UP"
}

locals {
  zones = coalescelist(try(var.vm_options.zones, []), data.google_compute_zones.zones.names)
}

module "regions" {
  source  = "memes/region-detail/google"
  version = "1.1.6"
  regions = [
    data.google_compute_subnetwork.outside.region,
  ]
}

resource "volterra_gcp_vpc_site" "site" {
  name          = var.name
  namespace     = "system"
  description   = coalesce(var.description, "GCP VPC Site")
  annotations   = var.annotations
  labels        = var.labels
  disk_size     = try(var.vm_options.disk_size, 80)
  gcp_labels    = var.gcp_labels
  gcp_region    = data.google_compute_subnetwork.outside.region
  instance_type = try(var.vm_options.instance_type, "e2-standard-8")
  # TODO @memes - nodes_per_az is not defined in the OpenAPI spec; is this used at all?
  nodes_per_az = try(var.vm_options.nodes_per_az, 0)
  ssh_key      = try(var.vm_options.ssh_key, null)

  coordinates {
    latitude  = module.regions.results[data.google_compute_subnetwork.outside.region].latitude
    longitude = module.regions.results[data.google_compute_subnetwork.outside.region].longitude
  }

  cloud_credentials {
    name      = var.cloud_credential_name
    namespace = "system"
  }

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
  default_blocked_services = try(length(var.site_options.blocked_services), 0) == 0

  dynamic "log_receiver" {
    for_each = try(length(var.site_options.log_receiver), 0) != 0 ? { params = var.site_options.log_receiver } : {}
    content {
      name      = log_receiver.value.name
      namespace = log_receiver.value.namespace
      tenant    = log_receiver.value.tenant
    }
  }
  logs_streaming_disabled = try(length(var.site_options.log_receiver), 0) == 0

  offline_survivability_mode {
    enable_offline_survivability_mode = try(var.site_options.offline_survivability_mode, false)
  }

  dynamic "os" {
    for_each = coalesce(try(var.vm_options.os_version, null), "default") == "default" ? { default_value = true } : {}
    content {
      default_os_version = os.value
    }
  }
  dynamic "os" {
    for_each = coalesce(try(var.vm_options.os_version, null), "default") == "default" ? {} : { version = var.vm_options.os_version }
    content {
      operating_system_version = os.value
    }
  }

  dynamic "sw" {
    for_each = coalesce(try(var.vm_options.sw_version, null), "default") == "default" ? { default_value = true } : {}
    content {
      default_sw_version = sw.value
    }
  }
  dynamic "sw" {
    for_each = coalesce(try(var.vm_options.sw_version, null), "default") == "default" ? {} : { version = var.vm_options.sw_version }
    content {
      volterra_software_version = sw.value
    }
  }

  ingress_egress_gw {
    gcp_certified_hw = "gcp-byol-multi-nic-voltmesh"
    gcp_zone_names   = local.zones
    node_number      = 3

    inside_network {
      existing_network {
        name = reverse(split("/", data.google_compute_subnetwork.inside.network))[0]
      }
    }

    inside_subnet {
      existing_subnet {
        subnet_name = reverse(split("/", data.google_compute_subnetwork.inside.self_link))[0]
      }
    }

    outside_network {
      existing_network {
        name = reverse(split("/", data.google_compute_subnetwork.outside.network))[0]
      }
    }

    outside_subnet {
      existing_subnet {
        subnet_name = reverse(split("/", data.google_compute_subnetwork.outside.self_link))[0]
      }
    }

    # DC cluster group can be established on one of inside or outside network
    dynamic "dc_cluster_group_inside_vn" {
      for_each = coalesce(try(var.dc_cluster_group.interface, "unspecified"), "unspecified") == "inside" ? { inside = var.dc_cluster_group } : {}
      content {
        name      = dc_cluster_group_inside_vn.value.name
        namespace = dc_cluster_group_inside_vn.value.namespace
        tenant    = dc_cluster_group_inside_vn.value.tenant
      }
    }
    dynamic "dc_cluster_group_outside_vn" {
      for_each = coalesce(try(var.dc_cluster_group.interface, "unspecified"), "unspecified") == "outside" ? { outside = var.dc_cluster_group } : {}
      content {
        name      = dc_cluster_group_outside_vn.value.name
        namespace = dc_cluster_group_outside_vn.value.namespace
        tenant    = dc_cluster_group_outside_vn.value.tenant
      }
    }
    no_dc_cluster_group = !contains(["inside", "outside"], coalesce(try(var.dc_cluster_group.interface, "unspecified"), "unspecified")) ? true : null

    dynamic "active_forward_proxy_policies" {
      for_each = try(length(var.forward_proxy_policies), 0) > 0 ? { policies = var.forward_proxy_policies } : {}
      content {
        dynamic "forward_proxy_policies" {
          for_each = active_forward_proxy_policies.value
          content {
            name      = forward_proxy_policies.value.name
            namespace = forward_proxy_policies.value.namespace
            tenant    = forward_proxy_policies.value.tenant
          }
        }
      }
    }
    forward_proxy_allow_all = var.forward_proxy_policies != null && try(length(var.forward_proxy_policies), 0) == 0 ? true : null
    no_forward_proxy        = var.forward_proxy_policies == null ? true : null

    dynamic "global_network_list" {
      for_each = var.global_networks != null && (try(var.global_networks.inside, null) != null || try(var.global_networks.outside, null) != null) ? { networks = var.global_networks } : {}
      content {
        dynamic "global_network_connections" {
          for_each = try(global_network_list.value.inside, null) != null ? { inside = global_network_list.value.inside } : {}
          content {
            sli_to_global_dr {
              global_vn {
                name      = global_network_connections.value.name
                namespace = global_network_connections.value.namespace
                tenant    = global_network_connections.value.tenant
              }
            }
            # TODO @memes - enable_forward_proxy property is not defined in OpenAPI spec
            # specification for ingress_egress_gw; investigate
            # dynamic "enable_forward_proxy" {
            #   for_each = try(global_network_connections.value.forward_proxy, null) != null ? { proxy = global_network_connections.value.forward_proxy } : {}
            #   content {
            #     connection_timeout   = 2000
            #     max_connect_attempts = 1
            #     tls_intercept {
            #       enable_for_all_domains = true
            #     }
            #     no_interception       = true
            #     white_listed_ports    = []
            #     white_listed_prefixes = []
            #   }
            # }
            # disable_forward_proxy = try(global_network_connections.value.forward_proxy, null) == null ? true : null
          }
        }
        dynamic "global_network_connections" {
          for_each = try(global_network_list.value.outside, null) != null ? { outside = global_network_list.value.outside } : {}
          content {
            slo_to_global_dr {
              global_vn {
                name      = global_network_connections.value.name
                namespace = global_network_connections.value.namespace
                tenant    = global_network_connections.value.tenant
              }
            }
            # TODO @memes - enable_forward_proxy property is not defined in OpenAPI spec
            # specification for ingress_egress_gw; investigate
            # dynamic "enable_forward_proxy" {
            #   for_each =try(global_network_connections.value.forward_proxy, null) != null ? { proxy = global_network_connections.value.forward_proxy } : {}
            #   content {
            #     connection_timeout   = 2000
            #     max_connect_attempts = 1
            #     tls_intercept {
            #       enable_for_all_domains = true
            #     }
            #     no_interception       = true
            #     white_listed_ports    = []
            #     white_listed_prefixes = []
            #   }
            # }
            # disable_forward_proxy = try(global_network_connections.value.forward_proxy, null) == null ? true : null
          }
        }


      }
    }
    no_global_network = var.global_networks == null || (try(var.global_networks.inside, null) == null && try(var.global_networks.outside, null) == null) ? true : null

    dynamic "inside_static_routes" {
      for_each = try(var.static_routes.inside, null) != null && (try(length(var.static_routes.inside.simple), 0) > 0 || try(length(var.static_routes.inside.custom), 0) > 0) ? { routes = var.static_routes.inside } : {}
      content {
        # GCP VPC site does not support simple static route assignment for internal
        # dynamic "static_route_list" {
        #   for_each = try(inside_static_routes.value.simple, null) != null && try(length(inside_static_routes.value.simple), 0) > 0 ? inside_static_routes.value.simple : []
        #   content {
        #     simple_static_route = static_route_list.value
        #   }
        # }

        dynamic "static_route_list" {
          for_each = try(inside_static_routes.value.custom, null) != null ? { for i, v in inside_static_routes.value.custom : "${i}" => v } : {}
          content {
            custom_static_route {
              attrs  = static_route_list.value.attrs
              labels = static_route_list.value.labels
              nexthop {
                type = static_route_list.value.type
                dynamic "interface" {
                  for_each = static_route_list.value.type == "NEXT_HOP_NETWORK_INTERFACE" && static_route_list.value.interface != null ? { interface = static_route_list.value.interface } : {}
                  content {
                    name      = interface.value.name
                    namespace = interface.value.namespace
                    tenant    = interface.value.tenant
                  }
                }
                dynamic "nexthop_address" {
                  for_each = static_route_list.value.type == "NEXT_HOP_USE_CONFIGURED" && static_route_list.value.address != null ? { address = static_route_list.value.address } : {}
                  content {
                    dynamic "ipv4" {
                      for_each = can(cidrnetmask(format("%s/32", nexthop_address.value))) ? { address = nexthop_address.value } : {}
                      content {
                        addr = ipv4.value
                      }
                    }
                    dynamic "ipv6" {
                      for_each = !can(cidrnetmask(format("%s/32", nexthop_address.value))) ? { address = nexthop_address.value } : {}
                      content {
                        addr = ipv6.value
                      }
                    }
                  }
                }
              }
              dynamic "subnets" {
                for_each = try([for subnet in static_route_list.value.subnets : subnet if can(cidrnetmask(subnet))], [])
                content {
                  ipv4 {
                    prefix = cidrhost(subnets.value, 0)
                    plen   = split("/", subnets.value)[1]
                  }
                }
              }
              dynamic "subnets" {
                for_each = try([for subnet in static_route_list.value.subnets : subnet if !can(cidrnetmask(subnet))], [])
                content {
                  ipv6 {
                    prefix = cidrhost(subnets.value, 0)
                    plen   = split("/", subnets.value)[1]
                  }
                }
              }
            }
          }
        }
      }
    }
    no_inside_static_routes = try(var.static_routes.inside, null) == null || (try(length(var.static_routes.inside.simple), 0) == 0 && try(length(var.static_routes.inside.custom), 0) == 0) ? true : null


    # Module consumers can specify one of enhanced firewall, or regular network
    # policies to add to the site.
    dynamic "active_enhanced_firewall_policies" {
      for_each = coalesce(try(var.network_policies.type, "unspecified"), "unspecified") == "enhanced_firewall" && try(length(var.network_policies.refs), 0) > 0 ? { policies = var.network_policies.refs } : {}
      content {
        dynamic "enhanced_firewall_policies" {
          for_each = active_enhanced_firewall_policies.value
          content {
            name      = enhanced_firewall_policies.value.name
            namespace = enhanced_firewall_policies.value.namespace
            tenant    = enhanced_firewall_policies.value.tenant
          }
        }
      }
    }
    dynamic "active_network_policies" {
      for_each = coalesce(try(var.network_policies.type, "unspecified"), "unspecified") == "network" && try(length(var.network_policies.refs), 0) > 0 ? { policies = var.network_policies.refs } : {}
      content {
        dynamic "network_policies" {
          for_each = active_network_policies.value
          content {
            name      = network_policies.value.name
            namespace = network_policies.value.namespace
            tenant    = network_policies.value.tenant
          }
        }
      }
    }
    no_network_policy = try(length(var.network_policies.refs), 0) == 0 ? true : null

    dynamic "outside_static_routes" {
      for_each = try(var.static_routes.outside, null) != null && (try(length(var.static_routes.outside.simple), 0) > 0 || try(length(var.static_routes.outside.custom), 0) > 0) ? { routes = var.static_routes.outside } : {}
      content {
        dynamic "static_route_list" {
          for_each = try(outside_static_routes.value.simple, null) != null && try(length(outside_static_routes.value.simple), 0) > 0 ? outside_static_routes.value.simple : []
          content {
            simple_static_route = static_route_list.value
          }
        }

        dynamic "static_route_list" {
          for_each = try(outside_static_routes.value.custom, null) != null && try(length(outside_static_routes.value.custom), 0) > 0 ? { custom = outside_static_routes.value.custom } : {}
          content {
            custom_static_route {
              attrs  = static_route_list.value.attrs
              labels = static_route_list.value.labels
              nexthop {
                type = static_route_list.value.type
                dynamic "interface" {
                  for_each = static_route_list.value.type == "NEXT_HOP_NETWORK_INTERFACE" && static_route_list.value.interface != null ? { interface = static_route_list.value.interface } : {}
                  content {
                    name      = interface.value.name
                    namespace = interface.value.namespace
                    tenant    = interface.value.tenant
                  }
                }
                dynamic "nexthop_address" {
                  for_each = static_route_list.value.type == "NEXT_HOP_USE_CONFIGURED" && static_route_list.value.address != null ? { address = static_route_list.value.address } : {}
                  content {
                    dynamic "ipv4" {
                      for_each = can(cidrnetmask(format("%s/32", nexthop_address.value))) ? { address = nexthop_address.value } : {}
                      content {
                        addr = ipv4.value
                      }
                    }
                    dynamic "ipv6" {
                      for_each = !can(cidrnetmask(format("%s/32", nexthop_address.value))) ? { address = nexthop_address.value } : {}
                      content {
                        addr = ipv6.value
                      }
                    }
                  }
                }
              }
              dynamic "subnets" {
                for_each = try([for subnet in static_route_list.value.subnets : subnet if can(cidrnetmask(subnet))], [])
                content {
                  ipv4 {
                    prefix = cidrhost(subnets.value, 0)
                    plen   = split("/", subnets.value)[1]
                  }
                }
              }
              dynamic "subnets" {
                for_each = try([for subnet in static_route_list.value.subnets : subnet if !can(cidrnetmask(subnet))], [])
                content {
                  ipv6 {
                    prefix = cidrhost(subnets.value, 0)
                    plen   = split("/", subnets.value)[1]
                  }
                }
              }
            }
          }
        }
      }
    }
    no_outside_static_routes = try(var.static_routes.outside, null) == null || (try(length(var.static_routes.outside.simple), 0) == 0 && try(length(var.static_routes.outside.custom), 0) == 0) ? true : null

    # Performance enhancement mode is optional, but if specified it must indicate
    # one of L3 or L7 enhanced performance modes.
    dynamic "performance_enhancement_mode" {
      for_each = contains(["l3_enhanced", "l7_enhanced"], coalesce(try(var.site_options.perf_mode, "unspecified"), "unspecified")) ? { perf_mode = var.site_options.perf_mode } : {}
      content {
        dynamic "perf_mode_l3_enhanced" {
          for_each = performance_enhancement_mode.value == "l3_enhanced" ? { jumbo = false } : {}
          content {
            # TODO @memes - revist
            # For now don't allow jumbo frames as most GCP VPCs are still running
            # at default mtu of 1460, but be ready to enable it.
            jumbo    = perf_mode_l3_enhanced.value ? true : null
            no_jumbo = !perf_mode_l3_enhanced.value ? true : null
          }
        }
        perf_mode_l7_enhanced = performance_enhancement_mode.value == "l7_enhanced" ? true : null
      }
    }

    # Site mesh connection is optional, but if specified it must indicate one of
    # public or private IP options.
    sm_connection_public_ip = coalesce(try(var.site_options.sm_connection, "unspecified"), "unspecified") == "public_ip" ? true : null
    sm_connection_pvt_ip    = coalesce(try(var.site_options.sm_connection, "unspecified"), "unspecified") == "pvt_ip" ? true : null
  }

  lifecycle {
    # Annotations and labels are often changed outside of provisioning, so ignore
    # any changes to those fields.
    ignore_changes = [
      annotations,
      labels,
    ]
  }
}

resource "volterra_tf_params_action" "site" {
  site_name        = volterra_gcp_vpc_site.site.name
  site_kind        = "gcp_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [
    volterra_gcp_vpc_site.site,
  ]
}
