run "setup" {
  command = apply

  module {
    source = "./tests/setup/state/"
  }

  assert {
    condition     = coalesce(try(data.terraform_remote_state.setup.outputs["prefix"], ""), "unspecified") != "unspecified"
    error_message = "Shared setup for test harness must be applied."
  }
}

run "null" {
  command = plan

  variables {
    name            = "${run.setup.prefix}-slo"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    slo_config      = null
  }
}

run "labels" {
  command = plan

  variables {
    name            = "${run.setup.prefix}-slo"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    slo_config = {
      labels = {
        slo_label = "labels"
      }
      nameserver    = null
      vip = null
      static_routes = null
    }
  }
}

run "ipv4" {
  command = plan

  variables {
    name            = "${run.setup.prefix}-slo"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    slo_config = {
      labels        = null
      nameserver    = "1.2.3.4"
      vip = "5.6.7.8"
      static_routes = null
    }
  }
}

run "ipv6" {
  command = plan

  variables {
    name            = "${run.setup.prefix}-slo"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    slo_config = {
      labels        = null
      nameserver    = "fd00::"
      vip = "fc00::"
      static_routes = null
    }
  }
}

run "provision" {
  command = apply

  variables {
    name            = "${run.setup.prefix}-slo"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    slo_config = {
      labels = {
        slo_label = "test"
      }
      nameserver = "10.0.0.1"
      vip = "10.100.0.1"
      static_routes = [
        {
          ip_address      = null
          default_gateway = true
          interface       = null
          attrs = [
            "ROUTE_ATTR_ADVERTISE",
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING",
          ]
          prefixes = [
            "192.168.1.0/28",
          ]
        },
      ]
    }
  }

  assert {
    condition     = coalesce(volterra_securemesh_site_v2.site.id, "unknown") != "unknown"
    error_message = "The SMSv2 site id was not found."
  }

  assert {
    condition     = volterra_securemesh_site_v2.site.description == "SMSv2 site for GCP"
    error_message = "Expected description to be 'SMSv2 site for GCP', got '${coalesce(volterra_securemesh_site_v2.site.description, "null")}'"
  }

  assert {
    condition     = try(length(volterra_securemesh_site_v2.site.local_vrf[0].slo_config), 0) > 0
    error_message = "Expected site to have custom slo_config"
  }

  assert {
    condition     = try(length(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].static_routes), 0) > 0
    error_message = "Expected site to have custom slo_config static routes"
  }

  assert {
    condition = try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver, "") == "10.0.0.1"
    error_message = "Expected site nameserver to be 10.0.0.1, got '${try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver, "")}'"
  }

  assert {
    condition = try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver_v6, "") == ""
    error_message = "Expected site nameserver_v6 to be empty, got '${try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver_v6, "")}'"
  }

  assert {
    condition = try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].vip, "") == "10.100.0.1"
    error_message = "Expected site vip to be 10.100.0.1, got '${try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver, "")}'"
  }

  assert {
    condition = try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].nameserver_v6, "") == ""
    error_message = "Expected site vip_v6 to be empty, got '${try(volterra_securemesh_site_v2.site.local_vrf[0].slo_config[0].vip_v6, "")}'"
  }

  assert {
    condition     = try(length(volterra_token.reg), 0) == 3
    error_message = "Expected 3 registration tokens, got ${try(length(volterra_token.reg), 0)}."
  }

  assert {
    condition     = try(length(google_compute_instance.node), 0) == 3
    error_message = "Expected 3 CE nodes, got ${try(length(google_compute_instance.node), 0)}."
  }

  assert {
    condition     = alltrue([for k, v in try(google_compute_instance.node, {}) : can(regex("-slo-0[012]$", v.name))])
    error_message = "Generated VM names do not match expectations, got '${join(",", [for k, v in try(google_compute_instance.node, {}) : v.name])}'"
  }
}

# run "pause" {
#   command = apply

#   module {
#     source = "./tests/modules/pause/"
#   }

#   variables {
#     destroy_duration = "600s"
#   }
# }
