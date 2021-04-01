variable "target_type" {
  type    = string
  default = "project"
  validation {
    condition     = contains(list("project", "org"), var.target_type)
    error_message = "The target_type variable must be one of 'project', or 'org'."
  }
  description = <<EOD
Determines if the Volterra role is to be created for the whole organization ('org')
or at a 'project' level. Default is 'project'.
EOD
}

variable "target_id" {
  type        = string
  description = <<EOD
Sets the target for Volterra role creation; must be either an organization ID
(target_type = 'org'), or project ID (target_type = 'project').
EOD
}

variable "id" {
  type    = string
  default = ""
  validation {
    condition     = var.id == "" || can(regex("^[a-z0-9_.]{3,64}$", var.id))
    error_message = "The id variable must be empty or between 3 and 64 characters in length and only contain alphanumeric, underscore and periods."
  }
  description = <<EOD
An identifier to use for the new role; default is an empty string which will
generate a unique identifier. If a value is provided, it must be unique at the
organization or project level depending on value of target_type respectively.
E.g. multiple projects can all have a 'volterra_vpc' role defined in each project,
but an organization level role must be uniquely named.
EOD
}

variable "title" {
  type    = string
  default = "Custom Volterra VPC role"
  validation {
    condition     = length(var.title) <= 100
    error_message = "The title variable must be empty, or up to 100 characters long."
  }
  description = <<EOD
The human-readable title to assign to the custom Volterra role. Default is
'Custom Volterra VPC role'.
EOD
}

variable "members" {
  type    = list(string)
  default = []
  validation {
    condition     = length(join("", [for member in var.members : can(regex("^(group|serviceAccount|user):[^@]+@[^@]+$", member)) ? "x" : ""])) == length(var.members)
    error_message = "Each member value must be a fully-qualified IAM email address. E.g. serviceAccount:foo@project.iam.gserviceaccount.com."
  }
  description = <<EOD
An optional list of accounts that will be assigned the custom role. Default is an empty list, meaning that the assignment of the role to accounts will happen
elsewhere.
EOD
}
