variable "project_id" {
  description = "Google Cloud project id."
  type        = string
}

variable "region" {
  description = "Region of the Autopilot cluster."
  type        = string
  default     = "europe-west1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
  default     = "agents"
}

variable "dns_zone_name" {
  description = "Name of the Cloud DNS managed zone (the zone resource name, not the domain)."
  type        = string
}

variable "agent_hostname" {
  description = "Fully qualified host of the agent, e.g. agent.example.com."
  type        = string
}

variable "acme_email" {
  description = "Email for the Let's Encrypt account."
  type        = string
}
