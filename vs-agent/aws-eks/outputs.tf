output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "load_balancer_hostname" {
  value = module.addons.load_balancer_hostname
}

output "agent_hostname" {
  value = aws_route53_record.agent.fqdn
}
