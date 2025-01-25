output "prefix" {
  value       = random_pet.prefix.id
  description = <<-EOD
  The combination of random and user-supplied elements that were used for this test suite run.
  EOD
}

output "subnet_self_links" {
  value = {
    outside = module.outside.subnets_by_region[var.region].self_link
    inside  = module.inside.subnets_by_region[var.region].self_link
  }
  description = <<-EOD
  Self-links for the outside and inside VPC networks created for shared test harness.
  EOD
}

output "inside_self_link" {
  value = module.inside.subnets_by_region[var.region].self_link
}

output "inside_global" {
  value = volterra_virtual_network.inside_global.name
}

output "inside_dc_group" {
  value = {
    name      = volterra_dc_cluster_group.dc_inside.name
    namespace = volterra_dc_cluster_group.dc_inside.namespace
  }
}

output "outside_self_link" {
  value = module.outside.subnets_by_region[var.region].self_link
}

output "outside_global" {
  value = volterra_virtual_network.outside_global.name
}

output "outside_dc_group" {
  value = {
    name      = volterra_dc_cluster_group.dc_outside.name
    namespace = volterra_dc_cluster_group.dc_outside.namespace
  }
}

output "forward_proxy_policy" {
  value = {
    name      = volterra_forward_proxy_policy.allow_test.name
    namespace = volterra_forward_proxy_policy.allow_test.namespace
  }
}

output "sa" {
  value = google_service_account.xc.email
}

output "custom_ce_image" {
  value = google_compute_image.xc.self_link
}

output "ssh_privkey_path" {
  value = abspath(local_file.ssh_privkey.filename)
}

output "ssh_pubkey_path" {
  value = abspath(local_file.ssh_pubkey.filename)
}

output "ssh_pubkey" {
  value = trimspace(tls_private_key.ssh.public_key_openssh)
}

output "labels" {
  value = var.labels
}

output "annotations" {
  value = var.annotations
}

output "gcp_labels" {
  value = var.gcp_labels
}

output "zones" {
  value = random_shuffle.zones.result
}

output "region" {
  value = var.region
}

output "namespace" {
  value = var.namespace
}

output "outside_nat_tags" {
  value = local.outside_nat_tags
}

output "inside_nat_tags" {
  value = local.inside_nat_tags
}

output "bastion" {
  value = {
    ssh    = module.outside_bastion.ssh_command
    tunnel = module.outside_bastion.tunnel_command
  }
}
