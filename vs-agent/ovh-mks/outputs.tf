output "cluster_id" {
  value = ovh_cloud_project_kube.agents.id
}

output "kubeconfig" {
  description = "Kubeconfig of the cluster; write it to a file with: terraform output -raw kubeconfig > agents.kubeconfig"
  value       = ovh_cloud_project_kube.agents.kubeconfig
  sensitive   = true
}

output "load_balancer_ip" {
  value = module.addons.load_balancer_ip
}

output "agent_hostname" {
  value = "${var.agent_record_name}.${var.dns_zone}"
}
