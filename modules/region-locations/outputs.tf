output "lookup" {
  value       = local.lookup
  description = <<EOD
A map of GCP compute region to a coordinate object with latitude and longitude
fields.
EOD
}
