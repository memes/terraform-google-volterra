output "smsv2_site_id" {
  value       = volterra_securemesh_site_v2.site.id
  description = <<-EOD
    The identifier of the F5 Distributed Cloud SMS v2 site.
    EOD
}

output "nodes" {
  value = { for k, v in google_compute_instance.node : k => {
    self_link     = v.self_link
    zone          = v.zone
    slo_ip        = v.network_interface[0].network_ip
    slo_public_ip = try(v.network_interface[0].access_config.nat_ip, null)
    sli_ip        = try(v.network_interface[1].network_ip, null)
    sli_public_ip = try(v.network_interface[1].access_config.nat_ip, null)
  } }
  description = <<-EOD
    A map of CE node names to values
    EOD
}

output "name" {
  value = var.name
}

output "namespace" {
  value = "system"
}
