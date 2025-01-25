terraform {
  required_version = ">= 1.2"
  required_providers {
    f5xc = {
      source  = "registry.terraform.io/memes/f5xc"
      version = ">= 0.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.17"
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
      source  = "registry.terraform.io/volterraedge/volterra"
      version = ">= 0.11.42"
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
  test_cidrs       = coalescelist(var.test_cidrs, [format("%s/32", trimspace(data.http.my_address.response_body))])
  outside_nat_tags = formatlist("%s-outside-nat", random_pet.prefix.id)
  inside_nat_tags  = formatlist("%s-outside-nat", random_pet.prefix.id)
}

resource "google_service_account" "xc" {
  project      = var.project_id
  account_id   = format("%s-xc", random_pet.prefix.id)
  display_name = format("XC (%s)", random_pet.prefix.id)
  description  = "Service account for F5 XC SMSv2 nodes"
}

# Add additional features to the F5 image
resource "google_compute_image" "xc" {
  project      = var.project_id
  name         = format("%s-ce", random_pet.prefix.id)
  description  = "Customised F5 XC CE image for testing"
  source_image = "https://www.googleapis.com/compute/v1/projects/f5-7626-networks-public/global/images/f5xc-ce-9202444-20241230010942"
  labels       = var.gcp_labels
  storage_locations = [
    var.region,
  ]
  guest_os_features {
    type = "GVNIC"
  }

  lifecycle {
    ignore_changes = [
      guest_os_features,
    ]
  }
}

module "outside" {
  source      = "memes/multi-region-private-network/google"
  version     = "3.1.0"
  project_id  = var.project_id
  name        = format("%s-outside", random_pet.prefix.id)
  description = format("Outside test VPC network (%s)", random_pet.prefix.id)
  regions = [
    var.region,
  ]
  cidrs = {
    primary_ipv4_cidr          = "172.16.0.0/16"
    primary_ipv4_subnet_size   = 24
    primary_ipv4_subnet_offset = 0
    primary_ipv4_subnet_step   = 10
    primary_ipv6_cidr          = null
    secondaries                = null
  }
  options = {
    delete_default_routes = true
    restricted_apis       = true
    nat                   = true
    nat_tags              = local.outside_nat_tags
    mtu                   = 1460
    routing_mode          = "REGIONAL"
    flow_logs             = false
    ipv6_ula              = false
    nat_logs              = false
    private_apis          = false
  }
}

# resource "google_compute_firewall" "outside_ingress" {
#   project = var.project_id
#   name = format("%s-outside-ingress", random_pet.prefix.id)
#   network = module.outside.self_link
#   description = "Allow ingress to CE service account"
#   direction = "INGRESS"
#   priority = 900
#   source_ranges = [
#     "0.0.0.0/0",
#   ]
#   target_service_accounts = [
#     google_service_account.xc.email,
#   ]
#   allow {
#     protocol = "all"
#   }

#   depends_on = [
#     google_service_account.xc,
#     module.outside,
#   ]
# }

resource "google_compute_firewall" "outside_egress" {
  project     = var.project_id
  name        = format("%s-outside-egress", random_pet.prefix.id)
  network     = module.outside.self_link
  description = "Allow egress from CE service account"
  direction   = "EGRESS"
  priority    = 900
  destination_ranges = [
    "0.0.0.0/0",
  ]
  target_service_accounts = [
    google_service_account.xc.email,
  ]
  allow {
    protocol = "all"
  }

  depends_on = [
    google_service_account.xc,
    module.outside,
  ]
}

module "inside" {
  source      = "memes/multi-region-private-network/google"
  version     = "3.1.0"
  project_id  = var.project_id
  name        = format("%s-inside", random_pet.prefix.id)
  description = format("Inside test VPC network (%s)", random_pet.prefix.id)
  regions     = [var.region]
  cidrs = {
    primary_ipv4_cidr          = "172.17.0.0/16"
    primary_ipv4_subnet_size   = 24
    primary_ipv4_subnet_offset = 0
    primary_ipv4_subnet_step   = 10
    primary_ipv6_cidr          = null
    secondaries = {
      pods = {
        ipv4_cidr          = "10.0.0.0/9"
        ipv4_subnet_size   = 16
        ipv4_subnet_offset = 0
        ipv4_subnet_step   = 10
      }
      services = {
        ipv4_cidr          = "10.128.0.0/16"
        ipv4_subnet_size   = 20
        ipv4_subnet_offset = 0
        ipv4_subnet_step   = 1
      }
    }
  }
  options = {
    delete_default_routes = true
    restricted_apis       = true
    nat                   = true
    nat_tags              = local.inside_nat_tags
    mtu                   = 1460
    routing_mode          = "REGIONAL"
    flow_logs             = false
    ipv6_ula              = false
    nat_logs              = false
    private_apis          = false
  }
}

# resource "google_compute_firewall" "inside_ingress" {
#   project = var.project_id
#   name = format("%s-inside-ingress", random_pet.prefix.id)
#   network = module.inside.self_link
#   description = "Allow ingress to CE service account"
#   direction = "INGRESS"
#   priority = 900
#   source_ranges = [
#     "0.0.0.0/0",
#   ]
#   target_service_accounts = [
#     google_service_account.xc.email,
#   ]
#   allow {
#     protocol = "all"
#   }

#   depends_on = [
#     google_service_account.xc,
#     module.inside,
#   ]
# }

resource "google_compute_firewall" "inside_egress" {
  project     = var.project_id
  name        = format("%s-inside-egress", random_pet.prefix.id)
  network     = module.inside.self_link
  description = "Allow egress from CE service account"
  direction   = "EGRESS"
  priority    = 900
  destination_ranges = [
    "0.0.0.0/0",
  ]
  target_service_accounts = [
    google_service_account.xc.email,
  ]
  allow {
    protocol = "all"
  }

  depends_on = [
    google_service_account.xc,
    module.inside,
  ]
}

module "dns" {
  source     = "memes/restricted-apis-dns/google"
  version    = "1.3.0"
  project_id = var.project_id
  network_self_links = [
    module.outside.self_link,
    module.inside.self_link,
  ]
  labels = var.gcp_labels
  depends_on = [
    module.outside,
    module.inside,
  ]
}

module "outside_bastion" {
  source                = "memes/private-bastion/google"
  version               = "3.1.1"
  project_id            = var.project_id
  name                  = format("%s-jmp", random_pet.prefix.id)
  zone                  = element(random_shuffle.zones.result, 0)
  subnet                = module.outside.subnets_by_region[var.region].self_link
  proxy_container_image = "ghcr.io/memes/terraform-google-private-bastion/forward-proxy:3.1.1"
  external_ip           = true
  source_cidrs          = local.test_cidrs
  bastion_targets = {
    service_accounts = null
    cidrs            = ["172.16.0.0/16"]
    priority         = 900
  }
  depends_on = [
    module.outside,
  ]
}

resource "volterra_dc_cluster_group" "dc_outside" {
  name        = format("%s-outside", random_pet.prefix.id)
  namespace   = "system"
  description = format("Outside DC cluster group (%s)", random_pet.prefix.id)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_virtual_network" "outside_global" {
  name           = format("%s-outside", random_pet.prefix.id)
  namespace      = "system"
  global_network = true
  description    = format("Outside test global network (%s)", random_pet.prefix.id)
  annotations    = var.annotations
  labels         = var.labels
}

resource "volterra_dc_cluster_group" "dc_inside" {
  name        = format("%s-inside", random_pet.prefix.id)
  namespace   = "system" # var.namespace
  description = format("Inside DC cluster group (%s)", random_pet.prefix.id)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_virtual_network" "inside_global" {
  name           = format("%s-inside", random_pet.prefix.id)
  namespace      = "system"
  global_network = true
  description    = format("Inside test global network (%s)", random_pet.prefix.id)
  annotations    = var.annotations
  labels         = var.labels
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_privkey" {
  filename        = format("%s/%s-ssh", path.module, random_pet.prefix.id)
  file_permission = "0600"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_file" "ssh_pubkey" {
  filename        = format("%s/%s-ssh.pub", path.module, random_pet.prefix.id)
  file_permission = "0600"
  content         = tls_private_key.ssh.public_key_openssh
}

resource "volterra_forward_proxy_policy" "allow_test" {
  name        = format("%s-allow-all", random_pet.prefix.id)
  namespace   = "system"
  any_proxy   = true
  allow_all   = true
  description = format("Test allow-all forward proxy policy (%s)", random_pet.prefix.id)
  annotations = var.annotations
  labels      = var.labels
}

resource "volterra_enhanced_firewall_policy" "allow_test" {
  name        = format("%s-allow-test", random_pet.prefix.id)
  namespace   = "system"
  description = format("Test enhanced firewall policy (%s)", random_pet.prefix.id)
  annotations = var.annotations
  labels      = var.labels
  allowed_sources {
    prefix = local.test_cidrs
  }
}

resource "google_compute_firewall" "test_ingress" {
  project       = var.project_id
  name          = format("%s-allow-outside-ingress", random_pet.prefix.id)
  network       = module.outside.self_link
  description   = format("Allow tester access to everything on outside VPC (%s)", random_pet.prefix.id)
  direction     = "INGRESS"
  source_ranges = local.test_cidrs
  target_service_accounts = [
    google_service_account.xc.email,
  ]
  allow {
    protocol = "all"
  }
  depends_on = [
    module.outside,
    google_service_account.xc,
  ]
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
    google_service_account.xc,
    google_compute_image.xc,
    module.inside,
    module.outside,
    module.outside_bastion,
    volterra_dc_cluster_group.dc_inside,
    volterra_virtual_network.inside_global,
    volterra_dc_cluster_group.dc_outside,
    volterra_virtual_network.outside_global,
    local_file.ssh_privkey,
    local_file.ssh_pubkey,
  ]
}
