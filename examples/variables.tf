

################################################################################
## shared
################################################################################
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Name of the environment the resource belongs to."
  type        = string
  default     = "DMS_POC"
}

variable "project_name" {
  description = "Name of the project the vpn resource belongs to."
  type        = string
  default     = "arc-tf-poc"
}
