resource "google_compute_instance" "default" {
  name         = "hashistack"
  machine_type = "n1-standard-1"
  zone         = "europe-west4-a"

  tags = ["owner", "jboero"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-8-v20210721"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    owner = "jboero"
    ttl = "30"
  }

  #metadata_startup_script = "echo hi > /test.txt"
  scheduling = {
    preemptible = true
    
  }
}
