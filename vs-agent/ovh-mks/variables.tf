variable "ovh_endpoint" {
  description = "OVHcloud API endpoint: ovh-eu, ovh-ca or ovh-us."
  type        = string
  default     = "ovh-eu"
}

variable "project_id" {
  description = "Public Cloud project id (the service_name of the API)."
  type        = string
}

variable "region" {
  description = "Region of the cluster, e.g. GRA11, SBG5, BHS5."
  type        = string
  default     = "GRA11"
}

variable "cluster_name" {
  description = "Name of the Managed Kubernetes cluster."
  type        = string
  default     = "agents"
}

variable "node_flavor" {
  description = "Flavor of the node pool. b3-8 is enough for a few agents."
  type        = string
  default     = "b3-8"
}

variable "node_count" {
  description = "Nodes in the pool."
  type        = number
  default     = 2
}

variable "dns_zone" {
  description = "DNS zone managed at OVHcloud, e.g. example.com."
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
