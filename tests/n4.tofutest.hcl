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
    condition     = try(length(volterra_token.reg), 0) == 3
    error_message = "Expected 3 registration tokens, got ${try(length(volterra_token.reg), 0)}."
  }

  assert {
    condition     = try(length(google_compute_instance.node), 0) == 3
    error_message = "Expected 3 CE node, got ${try(length(google_compute_instance.node), 0)}."
  }
}

run "pause" {
  command = apply

  module {
    source = "./tests/pause/"
  }

  variables {
    destroy_duration = "60s"
  }
}
