output "prefix" {
  value = data.terraform_remote_state.setup.outputs["prefix"]
}

output "subnet_self_links" {
  value = data.terraform_remote_state.setup.outputs["subnet_self_links"]
}

output "inside_self_link" {
  value = data.terraform_remote_state.setup.outputs["inside_self_link"]
}

output "inside_global" {
  value = data.terraform_remote_state.setup.outputs["inside_global"]
}

output "inside_dc_group" {
  value = data.terraform_remote_state.setup.outputs["inside_dc_group"]
}

output "outside_self_link" {
  value = data.terraform_remote_state.setup.outputs["outside_self_link"]
}

output "outside_global" {
  value = data.terraform_remote_state.setup.outputs["outside_global"]
}

output "outside_dc_group" {
  value = data.terraform_remote_state.setup.outputs["outside_dc_group"]
}

output "forward_proxy_policy" {
  value = data.terraform_remote_state.setup.outputs["forward_proxy_policy"]
}

output "sa" {
  value = data.terraform_remote_state.setup.outputs["sa"]
}

output "custom_ce_image" {
  value = data.terraform_remote_state.setup.outputs["custom_ce_image"]
}

output "ssh_privkey_path" {
  value = data.terraform_remote_state.setup.outputs["ssh_privkey_path"]
}

output "ssh_pubkey_path" {
  value = data.terraform_remote_state.setup.outputs["ssh_pubkey_path"]
}

output "ssh_pubkey" {
  value = data.terraform_remote_state.setup.outputs["ssh_pubkey"]
}

output "labels" {
  value = data.terraform_remote_state.setup.outputs["labels"]
}

output "annotations" {
  value = data.terraform_remote_state.setup.outputs["annotations"]
}

output "gcp_labels" {
  value = data.terraform_remote_state.setup.outputs["gcp_labels"]
}

output "zones" {
  value = data.terraform_remote_state.setup.outputs["zones"]
}

output "region" {
  value = data.terraform_remote_state.setup.outputs["region"]
}

output "namespace" {
  value = data.terraform_remote_state.setup.outputs["namespace"]
}

output "outside_nat_tags" {
  value = data.terraform_remote_state.setup.outputs["outside_nat_tags"]
}

output "inside_nat_tags" {
  value = data.terraform_remote_state.setup.outputs["inside_nat_tags"]
}

output "bastion" {
  value = data.terraform_remote_state.setup.outputs["bastion"]
}
