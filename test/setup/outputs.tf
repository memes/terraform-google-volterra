output "harness_yml" {
  value = abspath(local_file.harness_yml.filename)
}

output "prefix" {
  value = local.prefix
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

output "cloud_credential_name" {
  value = volterra_cloud_credentials.xc.name
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
  value = local.labels
}

output "annotations" {
  value = local.annotations
}

output "gcp_labels" {
  value = local.gcp_labels
}


output "zones" {
  value = random_shuffle.zones.result
}
