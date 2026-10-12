# Verana node on an Azure VM: resource group, VNet, NSG, static public IP, Ubuntu 24.04 VM,
# Premium SSD data disk at LUN 0, cloud-init via custom_data.

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "node" {
  name     = var.name
  location = var.location
}

resource "azurerm_virtual_network" "node" {
  name                = var.name
  location            = azurerm_resource_group.node.location
  resource_group_name = azurerm_resource_group.node.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "node" {
  name                 = "nodes"
  resource_group_name  = azurerm_resource_group.node.name
  virtual_network_name = azurerm_virtual_network.node.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "node" {
  name                = var.name
  location            = azurerm_resource_group.node.location
  resource_group_name = azurerm_resource_group.node.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.admin_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "p2p"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "26656"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.expose_rpc && length(var.rpc_cidrs) > 0 ? [1] : []
    content {
      name                       = "rpc"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["26657", "1317"]
      source_address_prefixes    = var.rpc_cidrs
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_public_ip" "node" {
  name                = var.name
  location            = azurerm_resource_group.node.location
  resource_group_name = azurerm_resource_group.node.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "node" {
  name                = var.name
  location            = azurerm_resource_group.node.location
  resource_group_name = azurerm_resource_group.node.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.node.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node.id
  }
}

resource "azurerm_network_interface_security_group_association" "node" {
  network_interface_id      = azurerm_network_interface.node.id
  network_security_group_id = azurerm_network_security_group.node.id
}

resource "azurerm_linux_virtual_machine" "node" {
  name                  = var.name
  location              = azurerm_resource_group.node.location
  resource_group_name   = azurerm_resource_group.node.name
  size                  = var.vm_size
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.node.id]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 50
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/../cloud-init.yaml.tftpl", {
    chain_id     = var.chain_id
    moniker      = var.moniker
    peers_file   = local.peers_file
    expose_rpc   = var.expose_rpc
    pruned       = var.pruned
    use_snapshot = var.use_snapshot
    data_device  = "/dev/disk/azure/scsi1/lun0"
  }))
}

resource "azurerm_managed_disk" "data" {
  name                 = "${var.name}-data"
  location             = azurerm_resource_group.node.location
  resource_group_name  = azurerm_resource_group.node.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_linux_virtual_machine.node.id
  lun                = 0
  caching            = "None"
}
