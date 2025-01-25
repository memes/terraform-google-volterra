# Try to launch an HA SMSv2 CE node on N4 machine type.
# NOTE: This test will fail with F5 published image because it isn't tagged with gvNIC support.
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

run "validate" {
  command = plan

  variables {
    name            = "${run.setup.prefix}-n4"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    machine_type = "n4-standard-8"
    image = run.setup.custom_ce_image
    vm_options = {
      disk_size = 80
      disk_type = "hyperdisk-balanced"
      os_version = null
      sw_version = null
      public_slo_ip = false
      public_sli_ip = false
      nic_type = "GVNIC"
    }
  }
}

run "provision" {
  command = apply

  variables {
    name            = "${run.setup.prefix}-n4"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
    machine_type = "n4-standard-8"
    image = run.setup.custom_ce_image
    vm_options = {
      disk_size = 80
      disk_type = "hyperdisk-balanced"
      os_version = null
      sw_version = null
      public_slo_ip = false
      public_sli_ip = false
      nic_type = "GVNIC"
    }
  }

  assert {
    condition     = coalesce(volterra_securemesh_site_v2.site.id, "unknown") != "unknown"
    error_message = "The SMSv2 site id was not found."
  }

  assert {
    condition = volterra_securemesh_site_v2.site.description == "SMSv2 site for GCP"
    error_message = "Expected description to be 'SMSv2 site for GCP', got '${coalesce(volterra_securemesh_site_v2.site.description, "null")}'"
  }

  assert {
    condition     = try(length(volterra_token.reg), 0) == 3
    error_message = "Expected 3 registration tokens, got ${try(length(volterra_token.reg), 0)}."
  }

  assert {
    condition     = try(length(google_compute_instance.node), 0) == 3
    error_message = "Expected 3 CE node, got ${try(length(google_compute_instance.node), 0)}."
  }

  assert {
    condition = alltrue([for k,v in try(google_compute_instance.node, {}): can(regex("-n4-0[012]$", v.name))])
    error_message = "Generated VM names do not match expectations, got '${join(",", [for k,v in try(google_compute_instance.node, {}):  v.name])}'"
  }
}

# run "pause" {
#   command = apply

#   module {
#     source = "./tests/modules/pause/"
#   }

#   variables {
#     destroy_duration = "60s"
#   }
# }
