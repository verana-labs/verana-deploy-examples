output "cluster_name" {
  value = azurerm_kubernetes_cluster.agents.name
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.agents.name} --name ${azurerm_kubernetes_cluster.agents.name}"
}

output "load_balancer_ip" {
  value = azurerm_public_ip.ingress.ip_address
}

output "agent_hostname" {
  value = "${var.agent_record_name}.${var.dns_zone_name}"
}
