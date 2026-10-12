variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "vm_size" {
  description = "Standard_D4s_v5 (4 vCPU, 16 GB)."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "name" {
  description = "Name of the resources (and of the resource group)."
  type        = string
  default     = "verana-node"
}
