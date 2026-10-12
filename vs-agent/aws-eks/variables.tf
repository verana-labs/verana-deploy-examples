variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "agents"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "Instance type of the managed node group. t3.medium is enough for a few agents."
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Nodes in the managed node group."
  type        = number
  default     = 2
}

variable "dns_zone_name" {
  description = "Route 53 hosted zone that holds the agent record, e.g. example.com."
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

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = { project = "verana-agents" }
}
