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
    name            = "${run.setup.prefix}-def"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
  }
}

run "provision" {
  command = apply

  variables {
    name            = "${run.setup.prefix}-def"
    subnets         = run.setup.subnet_self_links
    namespace       = run.setup.namespace
    ssh_key         = run.setup.ssh_pubkey
    service_account = run.setup.sa
    tags            = run.setup.outside_nat_tags
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
    condition     = try(length(volterra_token.reg), 0) == 3
    error_message = "Expected 3 registration tokens, got ${try(length(volterra_token.reg), 0)}."
  }

  assert {
    condition     = try(length(google_compute_instance.node), 0) == 3
    error_message = "Expected 3 CE nodes, got ${try(length(google_compute_instance.node), 0)}."
  }

  assert {
    condition     = alltrue([for k, v in try(google_compute_instance.node, {}) : can(regex("-def-0[012]$", v.name))])
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
