variable "region" {
  description = "OVHcloud Public Cloud region, e.g. GRA11, SBG5, BHS5, DE1, UK1."
  type        = string
  default     = "GRA11"
}

variable "flavor" {
  description = "b3-16 (4 vCPU, 16 GB); b3-8 is enough for a pruned full node."
  type        = string
  default     = "b3-16"
}

variable "volume_type" {
  description = "Block storage type: high-speed or classic."
  type        = string
  default     = "high-speed"
}

variable "name" {
  description = "Name of the resources."
  type        = string
  default     = "verana-node"
}
