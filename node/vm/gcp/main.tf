# Verana node on a Compute Engine instance in the default network: Ubuntu 24.04, pd-ssd data disk,
# firewall rules by network tag, static external address, cloud-init via user-data metadata.

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "node" {
  name = var.name
}

resource "google_compute_disk" "data" {
  name = "${var.name}-data"
  type = "pd-ssd"
  size = var.data_disk_gb
}

resource "google_compute_instance" "node" {
  name         = var.name
  machine_type = var.machine_type
  tags         = [var.name]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 50
      type  = "pd-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.data.id
    device_name = "data"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.node.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = templatefile("${path.module}/../cloud-init.yaml.tftpl", {
      chain_id     = var.chain_id
      moniker      = var.moniker
      peers_file   = local.peers_file
      expose_rpc   = var.expose_rpc
      pruned       = var.pruned
      use_snapshot = var.use_snapshot
      data_device  = "/dev/disk/by-id/google-data"
    })
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_firewall" "ssh" {
  name          = "${var.name}-ssh"
  network       = "default"
  target_tags   = [var.name]
  source_ranges = var.admin_cidrs

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "p2p" {
  name          = "${var.name}-p2p"
  network       = "default"
  target_tags   = [var.name]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["26656"]
  }
}

resource "google_compute_firewall" "rpc" {
  count = var.expose_rpc && length(var.rpc_cidrs) > 0 ? 1 : 0

  name          = "${var.name}-rpc"
  network       = "default"
  target_tags   = [var.name]
  source_ranges = var.rpc_cidrs

  allow {
    protocol = "tcp"
    ports    = ["26657", "1317"]
  }
}
