terraform {
  required_version = ">= 1.2"
  required_providers {
    # TODO @memes - test harness requires pre-release of terrform-provider-f5xc for blindfold
    f5xc = {
      source = "memes/f5xc"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 5.22"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.31"
    }
  }
}

data "http" "my_address" {
  url = "https://checkip.amazonaws.com"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to get local IP address"
    }
  }
}

data "google_compute_zones" "zones" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

resource "random_pet" "prefix" {
  length = 1
  prefix = coalesce(var.prefix, "gvpc")
  keepers = {
    project_id = var.project_id
  }
}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.zones.names
  keepers = {
    project_id = var.project_id
    region     = var.region
  }
}

locals {
  prefix     = random_pet.prefix.id
  test_cidrs = coalescelist(var.test_cidrs, [format("%s/32", trimspace(data.http.my_address.response_body))])
  cidrs = {
    outside = {
      primary_ipv4_cidr        = "172.16.0.0/16"
      primary_ipv4_subnet_size = 24
      primary_ipv6_cidr        = null
      secondaries              = null
    }
    inside = {
      primary_ipv4_cidr        = "172.17.0.0/16"
      primary_ipv4_subnet_size = 24
      primary_ipv6_cidr        = null
      secondaries = {
        pods = {
          ipv4_cidr        = "10.0.0.0/9"
          ipv4_subnet_size = 16
        }
        services = {
          ipv4_cidr        = "10.128.0.0/16"
          ipv4_subnet_size = 20
        }
      }
    }
  }
}

module "outside" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  project_id  = var.project_id
  name        = format("%s-outside", local.prefix)
  description = format("Outside test VPC network (%s)", local.prefix)
  regions     = [var.region]
  cidrs       = local.cidrs.outside
  options = {
    delete_default_routes = false
    restricted_apis       = false
    nat                   = false
    nat_tags              = []
    mtu                   = 1460
    routing_mode          = "GLOBAL"
    flow_logs             = false
    ipv6_ula              = false
    nat_logs              = false
  }
}

resource "volterra_dc_cluster_group" "dc_outside" {
  name        = format("%s-outside", local.prefix)
  namespace   = "system" # var.namespace
  description = format("Outside DC cluster group (%s)", local.prefix)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_virtual_network" "outside_global" {
  name           = format("%s-outside", local.prefix)
  namespace      = "system"
  global_network = true
  description    = format("Outside test global network (%s)", local.prefix)
  annotations    = var.annotations
  labels         = var.labels
}

module "inside" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  project_id  = var.project_id
  name        = format("%s-inside", local.prefix)
  description = format("Inside test VPC network (%s)", local.prefix)
  regions     = [var.region]
  cidrs       = local.cidrs.inside
  options = {
    delete_default_routes = false
    restricted_apis       = false
    nat                   = false
    nat_tags              = []
    mtu                   = 1460
    routing_mode          = "GLOBAL"
    flow_logs             = false
    ipv6_ula              = false
    nat_logs              = false
  }
}

resource "volterra_dc_cluster_group" "dc_inside" {
  name        = format("%s-inside", local.prefix)
  namespace   = "system" # var.namespace
  description = format("Inside DC cluster group (%s)", local.prefix)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_virtual_network" "inside_global" {
  name           = format("%s-inside", local.prefix)
  namespace      = "system"
  global_network = true
  description    = format("Inside test global network (%s)", local.prefix)
  annotations    = var.annotations
  labels         = var.labels
}

resource "google_compute_firewall" "test_ingress" {
  project       = var.project_id
  name          = format("%s-allow-outside-ingress", local.prefix)
  network       = module.outside.self_link
  description   = format("Allow tester access to everything on outside VPC (%s)", local.prefix)
  direction     = "INGRESS"
  source_ranges = local.test_cidrs
  target_service_accounts = [
    google_service_account.xc.email,
  ]
  allow {
    protocol = "TCP"
  }
  depends_on = [
    module.outside,
  ]
}

resource "google_service_account" "xc" {
  project      = var.project_id
  account_id   = format("%s-xc", local.prefix)
  display_name = format("XC (%s)", local.prefix)
  description  = "Service account for F5 XC GCP VPC management"
}

resource "google_service_account_key" "xc" {
  service_account_id = google_service_account.xc.id
  key_algorithm      = "KEY_ALG_RSA_2048"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
  keepers = {
    name = google_service_account.xc.name
  }
}

module "xc_role" {
  source           = "memes/f5-distributed-cloud-role/google"
  version          = "1.0.7"
  target_id        = var.project_id
  random_id_prefix = replace(format("%s-xc", local.prefix), "/[^a-z0-9_.]/", "_")
  title            = "F5 XC role for Google VPC testing"
  description      = "Custom role for F5 XC GCP VPC site creation and management"
}

resource "google_project_iam_member" "xc" {
  project = var.project_id
  role    = module.xc_role.qualified_role_id
  member  = google_service_account.xc.member

  depends_on = [
    google_service_account.xc,
    module.xc_role,
  ]
}

resource "f5xc_blindfold" "xc" {
  plaintext = google_service_account_key.xc.private_key
  policy_document = {
    name      = "ves-io-allow-volterra"
    namespace = "shared"
  }
}

resource "volterra_cloud_credentials" "xc" {
  name        = format("%s-gcp", local.prefix)
  namespace   = "system"
  description = format("GCP credentials (%s)", local.prefix)
  annotations = var.annotations
  labels      = var.labels
  gcp_cred_file {
    credential_file {
      blindfold_secret_info {
        location = format("string:///%s", f5xc_blindfold.xc.sealed)
      }
    }
  }
  depends_on = [
    google_service_account.xc,
    google_service_account_key.xc,
  ]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_privkey" {
  filename        = format("%s/%s-ssh", path.module, local.prefix)
  file_permission = "0600"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_file" "ssh_pubkey" {
  filename        = format("%s/%s-ssh.pub", path.module, local.prefix)
  file_permission = "0600"
  content         = tls_private_key.ssh.public_key_openssh
}

resource "volterra_forward_proxy_policy" "allow_test" {
  name        = format("%s-allow-all", local.prefix)
  namespace   = "system"
  any_proxy   = true
  allow_all   = true
  description = format("Test allow-all forward proxy policy (%s)", local.prefix)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_enhanced_firewall_policy" "allow_test" {
  name        = format("%s-allow-test", local.prefix)
  namespace   = "system"
  description = format("Test enhanced firewall policy (%s)", local.prefix)
  annotations = var.annotations
  labels      = var.labels
  allowed_sources {
    prefix = local.test_cidrs
  }
}

# Create an inspec attributes file for values that are shared between scenarios
resource "local_file" "harness_yml" {
  filename = "${path.module}/harness.yml"
  content  = <<-EOC
  project_id: ${var.project_id}
  region: ${var.region}
  ssh_key: ${trimspace(tls_private_key.ssh.public_key_openssh)}
  vpcs:
    outside:
      self_link: ${module.outside.self_link}
    inside:
      self_link: ${module.inside.self_link}
  EOC
  depends_on = [
    module.inside,
    module.outside,
    volterra_dc_cluster_group.dc_inside,
    volterra_virtual_network.inside_global,
    volterra_dc_cluster_group.dc_outside,
    volterra_virtual_network.outside_global,
    volterra_cloud_credentials.xc,
    local_file.ssh_privkey,
    local_file.ssh_pubkey,
  ]
}
