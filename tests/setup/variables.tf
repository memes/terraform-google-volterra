variable "prefix" {
  type    = string
  default = "gvpc"
}

variable "project_id" {
  type = string
}

# Prefer us-central1 region because it tends to have all machine types available
variable "region" {
  type    = string
  default = "us-central1"
}

variable "namespace" {
  type = string
}

variable "test_cidrs" {
  type    = list(any)
  default = []
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "gcp_labels" {
  type    = map(string)
  default = {}
}
