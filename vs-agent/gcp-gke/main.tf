# GKE Autopilot cluster for VS Agents: the cluster, a reserved external address, ingress-nginx
# bound to it, cert-manager, and a Cloud DNS record. Autopilot provides the standard-rwo storage class.

resource "google_project_service" "apis" {
  for_each = toset(["container.googleapis.com", "dns.googleapis.com", "compute.googleapis.com"])

  service            = each.key
  disable_on_destroy = false
}

resource "google_container_cluster" "agents" {
  depends_on = [google_project_service.apis]

  name     = var.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {}
}

# A static address keeps the DNS record valid when the ingress controller is recreated.
resource "google_compute_address" "ingress" {
  depends_on = [google_project_service.apis]

  name   = "${var.cluster_name}-ingress"
  region = var.region
}

module "addons" {
  source     = "../../modules/k8s-addons"
  depends_on = [google_container_cluster.agents]

  acme_email       = var.acme_email
  load_balancer_ip = google_compute_address.ingress.address
}

data "google_dns_managed_zone" "zone" {
  name = var.dns_zone_name
}

resource "google_dns_record_set" "agent" {
  managed_zone = data.google_dns_managed_zone.zone.name
  name         = "${var.agent_hostname}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.ingress.address]
}
