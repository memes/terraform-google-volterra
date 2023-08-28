variable "prefix" {
  type    = string
  default = "gvpc"
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
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
