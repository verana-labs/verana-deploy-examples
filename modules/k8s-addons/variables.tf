variable "ingress_nginx_version" {
  description = "Version of the ingress-nginx Helm chart."
  type        = string
  default     = "4.12.1"
}

variable "cert_manager_version" {
  description = "Version of the cert-manager Helm chart."
  type        = string
  default     = "v1.17.2"
}

variable "acme_email" {
  description = "Email address Let's Encrypt notifies about expiring certificates."
  type        = string
}

variable "load_balancer_ip" {
  description = "Static address to bind the ingress controller's Service to. Leave empty to let the provider assign one."
  type        = string
  default     = ""
}

variable "load_balancer_annotations" {
  description = "Provider-specific annotations for the ingress controller's Service (load balancer type, resource group, ...)."
  type        = map(string)
  default     = {}
}

variable "ingress_nginx_extra_values" {
  description = "Extra values merged into the ingress-nginx release, as a YAML string."
  type        = string
  default     = ""
}
