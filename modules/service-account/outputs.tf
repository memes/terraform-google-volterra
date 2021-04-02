output "role_id" {
  value       = module.role.qualified_role_id
  description = <<EOD
The qualified role-id for the custom Volterra role.
EOD
}

output "gcp_service_account" {
  value       = module.sa.email
  description = <<EOD
The fully-qualified GCP service account that was created.
EOD
}

output "cloud_credential_name" {
  value       = volterra_cloud_credentials.sa.name
  description = <<EOD
The name of the Volterra cloud credential containing the GCP service account
credentials file.
EOD
}

output "cloud_credential_namespace" {
  value       = volterra_cloud_credentials.sa.namespace
  description = <<EOD
The namespace containing the Volterra cloud credential for GCP service account.
EOD
}
