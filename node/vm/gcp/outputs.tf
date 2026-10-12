output "public_ip" {
  value = google_compute_address.node.address
}

output "instance" {
  value = google_compute_instance.node.name
}
