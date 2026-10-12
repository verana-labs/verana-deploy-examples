output "load_balancer_ip" {
  description = "Public IP of the ingress controller (empty on providers that hand out a hostname instead)."
  value       = try(data.kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, "")
}

output "load_balancer_hostname" {
  description = "Public hostname of the ingress controller (AWS); empty where the provider gives an IP."
  value       = try(data.kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname, "")
}
