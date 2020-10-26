provider "google" {
  version = "1.4.0"
  project = "hardy-city-293219"
  region  = "europe-west1-b"
}

resource "google_compute_instance" "app" {
  metadata {
    ssh-keys = "zhorshua:${file("~/igor.pub")}"
  }

  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  connection {
    type = "ssh"
    user = "zhorshua"
    agent = false
    private_key = "${file("~/igor")}"
  }

  provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "./files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

