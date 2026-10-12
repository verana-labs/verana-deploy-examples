# OVHcloud Managed Kubernetes for VS Agents, what the Verana testnet services run on: the cluster,
# a node pool, ingress-nginx behind an OVHcloud load balancer, cert-manager, and a DNS record in an
# OVHcloud zone. The cluster ships the csi-cinder-high-speed storage class, the chart's default.

resource "ovh_cloud_project_kube" "agents" {
  service_name = var.project_id
  name         = var.cluster_name
  region       = var.region
}

resource "ovh_cloud_project_kube_nodepool" "pool" {
  service_name  = var.project_id
  kube_id       = ovh_cloud_project_kube.agents.id
  name          = "pool"
  flavor_name   = var.node_flavor
  desired_nodes = var.node_count
  min_nodes     = var.node_count
  max_nodes     = var.node_count + 1
}

module "addons" {
  source     = "../../modules/k8s-addons"
  depends_on = [ovh_cloud_project_kube_nodepool.pool]

  acme_email = var.acme_email
}

resource "ovh_domain_zone_record" "agent" {
  zone      = var.dns_zone
  subdomain = var.agent_record_name
  fieldtype = "A"
  ttl       = 300
  target    = module.addons.load_balancer_ip
}
