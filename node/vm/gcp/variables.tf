variable "project_id" {
  description = "Google Cloud project id."
  type        = string
}

variable "region" {
  description = "Region."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone of the instance."
  type        = string
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "n2-standard-4 (4 vCPU, 16 GB)."
  type        = string
  default     = "n2-standard-4"
}

variable "name" {
  description = "Name of the resources."
  type        = string
  default     = "verana-node"
}
