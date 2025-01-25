variable "create_duration" {
  type     = string
  nullable = true
  validation {
    condition     = coalesce(var.create_duration, "unspecified") == "unspecified" ? true : can(regex("^[0-9]+(?:[hms]|ms)$", var.create_duration))
    error_message = "If specified, create_duration must be a valid Go duration string."
  }
  default     = null
  description = <<-EOD
    The duration to pause during resource creation phase. The default value will
    not generate a pause during creation; a value must be provided to force a
    delay. Format should be a positive integer followed by one of h, m, s, or
    ms.
    EOD
}

variable "destroy_duration" {
  type     = string
  nullable = true
  validation {
    condition     = coalesce(var.destroy_duration, "unspecified") == "unspecified" ? true : can(regex("^[0-9]+(?:[hms]|ms)$", var.destroy_duration))
    error_message = "If specified, destroy_duration must be a valid Go duration string."
  }
  default     = null
  description = <<-EOD
    The duration to pause during resource destruction phase. The default value
    will not generate a pause during creation; a value must be provided to force
    a delay. Format should be a positive integer followed by one of h, m, s, or
    ms.
    EOD
}
