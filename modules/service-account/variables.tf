variable "gcp_project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_project_id))
    error_message = "The gcp_project_id variable must be a valid GCP project id."
  }
  description = <<EOD
Sets the GCP project id for resource creation.
EOD
}

variable "gcp_role_name" {
  type    = string
  default = ""
  validation {
    condition     = var.gcp_role_name == "" || can(regex("^[a-z][a-z0-9-.]{1,63}[a-z0-9]$", var.gcp_role_name))
    error_message = "The gcp_role_name variable must be empty or between 3 and 64 alphanumeric characters, underscores (_), and periods (.)."
  }
  description = <<EOD
The name to assign to the generated custom IAM role; if left blank (default) a
semi-random name will be generated.
EOD
}

variable "gcp_service_account_name" {
  type    = string
  default = ""
  validation {
    condition     = var.gcp_service_account_name == "" || can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_service_account_name))
    error_message = "The gcp_service_account_name variable must be empty or between 6 and 30 characters that meet RFC1035 characters."
  }
  description = <<EOD
The name to assign to the generated service account; if left blank (default) a
semi-random name will be generated.
EOD
}

variable "cloud_credential_name" {
  type    = string
  default = ""
  validation {
    condition     = var.cloud_credential_name == "" || can(regex("^[a-z][a-z0-9-]{1,61}[a-z0-9]$", var.cloud_credential_name))
    error_message = "The cloud_credential_name variable must be empty or between 2 and 63 characters that meet RFC1035 characters."
  }
  description = <<EOD
The name to assign to the Volterra Cloud Credentials that will contain the GCP
service account JSON keyfile. See also `volterra_namespace`.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional list of labels to apply to generated Volterra cloud credentials.
EOD
}

variable "annotations" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional list of annotations to apply to generated Volterra cloud credentials.
EOD
}
