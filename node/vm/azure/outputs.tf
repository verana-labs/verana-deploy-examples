output "public_ip" {
  value = azurerm_public_ip.node.ip_address
}

output "resource_group" {
  value = azurerm_resource_group.node.name
}
