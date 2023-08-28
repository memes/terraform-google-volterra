terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      version = ">= 4.57"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.20"
    }
  }
}

locals {
  # Set semi-random name if the caller has not provided specifics
  sa_name = coalesce(var.gcp_service_account_name, format("volterra-site-%s", random_id.sa_id.hex))
  # Generated service account name is predictable
  sa_email = format("%s@%s.iam.gserviceaccount.com", local.sa_name, var.gcp_project_id)
}

resource "random_id" "sa_id" {
  byte_length = 4

  keepers = {
    gcp_project_id = var.gcp_project_id
  }
}

module "sa" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "4.0.2"
  project_id   = var.gcp_project_id
  prefix       = ""
  names        = [local.sa_name]
  descriptions = ["Volterra GCP VPC service account"]
  # NOTE: generate a JSON key to be stuffed into Cloud Credential
  generate_keys = true
}

# Create a custom role for Volterra VPC
module "role" {
  source      = "../role/"
  id          = var.gcp_role_name
  target_type = "project"
  target_id   = var.gcp_project_id
  members = [
    format("serviceAccount:%s", local.sa_email)
  ]
  depends_on = [module.sa]
}

resource "volterra_cloud_credentials" "sa" {
  name        = coalesce(var.cloud_credential_name, local.sa_name)
  namespace   = "system"
  description = format("Volterra GCP Site credentials for %s", local.sa_email)
  annotations = merge(var.annotations, {
    provisioner = "terraform"
    source      = "memes/volterra/google//modules/service-account"
    version     = "0.2.0"
  })
  labels = var.labels
  gcp_cred_file {
    credential_file {
      clear_secret_info {
        url = format("string:///%s", base64encode(module.sa.key))
      }
    }
  }
  depends_on = [module.sa]
}
