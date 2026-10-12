# Verana node on an OVHcloud Public Cloud instance, through the OpenStack API: Ubuntu 24.04 on
# Ext-Net (public address), a high-speed block volume, a security group, cloud-init as user_data.
# Credentials come from the OpenRC file of the project (source openrc.sh): OS_AUTH_URL, OS_USERNAME,
# OS_PASSWORD, OS_TENANT_ID, OS_REGION_NAME.

provider "openstack" {
  region = var.region
}

data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 24.04"
  most_recent = true
}

data "openstack_networking_network_v2" "ext" {
  name = "Ext-Net"
}

resource "openstack_compute_keypair_v2" "node" {
  name       = var.name
  public_key = var.ssh_public_key
}

resource "openstack_networking_secgroup_v2" "node" {
  name        = var.name
  description = "Verana node"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  for_each = toset(var.admin_cidrs)

  security_group_id = openstack_networking_secgroup_v2.node.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
}

resource "openstack_networking_secgroup_rule_v2" "p2p" {
  security_group_id = openstack_networking_secgroup_v2.node.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 26656
  port_range_max    = 26656
  remote_ip_prefix  = "0.0.0.0/0"
}

locals {
  rpc_rules = var.expose_rpc ? { for pair in setproduct(var.rpc_cidrs, [26657, 1317]) : "${pair[0]}-${pair[1]}" => { cidr = pair[0], port = pair[1] } } : {}
}

resource "openstack_networking_secgroup_rule_v2" "rpc" {
  for_each = local.rpc_rules

  security_group_id = openstack_networking_secgroup_v2.node.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
}

resource "openstack_blockstorage_volume_v3" "data" {
  name        = "${var.name}-data"
  size        = var.data_disk_gb
  volume_type = var.volume_type
}

resource "openstack_compute_instance_v2" "node" {
  name            = var.name
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.node.name
  security_groups = [openstack_networking_secgroup_v2.node.name]

  network {
    uuid = data.openstack_networking_network_v2.ext.id
  }

  # OpenStack exposes a virtio volume as /dev/disk/by-id/virtio-<first 20 chars of the volume id>.
  user_data = templatefile("${path.module}/../cloud-init.yaml.tftpl", {
    chain_id     = var.chain_id
    moniker      = var.moniker
    peers_file   = local.peers_file
    expose_rpc   = var.expose_rpc
    pruned       = var.pruned
    use_snapshot = var.use_snapshot
    data_device  = "/dev/disk/by-id/virtio-${substr(openstack_blockstorage_volume_v3.data.id, 0, 20)}"
  })
}

resource "openstack_compute_volume_attach_v2" "data" {
  instance_id = openstack_compute_instance_v2.node.id
  volume_id   = openstack_blockstorage_volume_v3.data.id
}
