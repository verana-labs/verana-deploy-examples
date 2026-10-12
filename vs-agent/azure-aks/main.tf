# AKS cluster for VS Agents: resource group, cluster with a small default node pool, a static
# public IP in the node resource group, ingress-nginx bound to it, cert-manager, and an Azure DNS
# record. AKS provides the managed-csi storage class.

resource "azurerm_resource_group" "agents" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "agents" {
  name                = var.cluster_name
  location            = azurerm_resource_group.agents.location
  resource_group_name = azurerm_resource_group.agents.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

# The IP lives in the node resource group so the cluster's identity can bind it.
resource "azurerm_public_ip" "ingress" {
  name                = "${var.cluster_name}-ingress"
  location            = azurerm_resource_group.agents.location
  resource_group_name = azurerm_kubernetes_cluster.agents.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "addons" {
  source     = "../../modules/k8s-addons"
  depends_on = [azurerm_kubernetes_cluster.agents]

  acme_email       = var.acme_email
  load_balancer_ip = azurerm_public_ip.ingress.ip_address
  load_balancer_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-resource-group" = azurerm_kubernetes_cluster.agents.node_resource_group
  }
}

data "azurerm_dns_zone" "zone" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}

resource "azurerm_dns_a_record" "agent" {
  name                = var.agent_record_name
  zone_name           = data.azurerm_dns_zone.zone.name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.ingress.ip_address]
}
