output "cluster_name" {
  value = google_container_cluster.agents.name
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.agents.name} --region ${var.region} --project ${var.project_id}"
}

output "load_balancer_ip" {
  value = google_compute_address.ingress.address
}

output "agent_hostname" {
  value = var.agent_hostname
}
