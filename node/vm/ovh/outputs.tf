output "public_ip" {
  value = openstack_compute_instance_v2.node.access_ip_v4
}

output "instance_id" {
  value = openstack_compute_instance_v2.node.id
}
