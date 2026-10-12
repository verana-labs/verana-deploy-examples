variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group created for the cluster."
  type        = string
  default     = "agents"
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "agents"
}

variable "node_vm_size" {
  description = "VM size of the default node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  description = "Nodes in the default node pool."
  type        = number
  default     = 2
}

variable "dns_zone_name" {
  description = "Azure DNS zone, e.g. example.com."
  type        = string
}

variable "dns_zone_resource_group" {
  description = "Resource group that holds the DNS zone."
  type        = string
}

variable "agent_record_name" {
  description = "Record name inside the zone, e.g. agent for agent.example.com."
  type        = string
  default     = "agent"
}

variable "acme_email" {
  description = "Email for the Let's Encrypt account."
  type        = string
}
