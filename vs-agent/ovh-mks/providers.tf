# Credentials come from the environment: OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET,
# OVH_CONSUMER_KEY (create them at https://www.ovh.com/auth/api/createToken with
# GET/POST/PUT/DELETE on /cloud/project/* and /domain/zone/*).
provider "ovh" {
  endpoint = var.ovh_endpoint
}

locals {
  kube = ovh_cloud_project_kube.agents.kubeconfig_attributes[0]
}

provider "kubernetes" {
  host                   = local.kube.host
  client_certificate     = base64decode(local.kube.client_certificate)
  client_key             = base64decode(local.kube.client_key)
  cluster_ca_certificate = base64decode(local.kube.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = local.kube.host
    client_certificate     = base64decode(local.kube.client_certificate)
    client_key             = base64decode(local.kube.client_key)
    cluster_ca_certificate = base64decode(local.kube.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = local.kube.host
  client_certificate     = base64decode(local.kube.client_certificate)
  client_key             = base64decode(local.kube.client_key)
  cluster_ca_certificate = base64decode(local.kube.cluster_ca_certificate)
  load_config_file       = false
}
