output "subnets_json" {
  value = jsonencode(var.subnets)
}

output "vm_options_json" {
  value = jsonencode(var.vm_options)
}
