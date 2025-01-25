variable "create_duration" {
  type        = string
  default     = "10s"
  description = <<-EOD
    The duration to pause during resource creation phase. Default generates a 10s pause.
    EOD
}

variable "destroy_duration" {
  type        = string
  default     = "10s"
  description = <<-EOD
    The duration to pause during resource destruction phase. Default generates a 10s pause.
    EOD
}
