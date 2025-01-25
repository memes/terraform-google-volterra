output "smsv2_site_id" {
  value       = volterra_securemesh_site_v2.site.id
  description = <<-EOD
    The identifier of the F5 Distributed Cloud SMS v2 site.
    EOD
}

output "nodes" {
  value = { for k, v in google_compute_instance.node : k => {
    self_link = v.self_link
    zone      = v.zone
  } }
  description = <<-EOD
    A map of CE node names to values
    EOD
}
