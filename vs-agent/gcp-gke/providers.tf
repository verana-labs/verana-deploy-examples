provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "current" {}

locals {
  k8s_host = "https://${google_container_cluster.agents.endpoint}"
  k8s_ca   = base64decode(google_container_cluster.agents.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" {
  host                   = local.k8s_host
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = local.k8s_ca
}

provider "helm" {
  kubernetes = {
    host                   = local.k8s_host
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = local.k8s_ca
  }
}

provider "kubectl" {
  host                   = local.k8s_host
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = local.k8s_ca
  load_config_file       = false
}
