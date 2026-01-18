resource "google_service_account" "openwebui" {
  account_id   = "openwebui"
  display_name = "Custom SA for VM Instance"
}

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
  
}

resource "google_compute_instance" "openwebui" {
  name         = "openwebui"
  machine_type = "n2-standard-2"
  zone         = "europe-west1-b"  

  tags = ["ssh"]

  boot_disk {
    initialize_params {
      image  = data.google_compute_image.debian.self_link
      size   = 200
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "openwebui:${file("~/.ssh/id_rsa.pub")} openwebui"
  }

  service_account {
    email = google_service_account.openwebui.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "ssh" {
  name = "ssh-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  target_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}