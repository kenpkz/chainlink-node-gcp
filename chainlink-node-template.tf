resource "google_service_account" "default" {
  project = var.project
  account_id   = "chainlink-sa"
  display_name = "Chainlink Node Service Account"
}

resource "google_project_iam_binding" "logging" {
  project = var.project
  role    = "roles/logging.logWriter"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_project_iam_binding" "monitoring" {
  project = var.project
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_project_iam_binding" "monitoringviewer" {
  project = var.project
  role    = "roles/monitoring.viewer"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_project_iam_binding" "metadata" {
  project = var.project
  role    = "roles/stackdriver.resourceMetadata.writer"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_project_iam_binding" "secretmanager" {
  project = var.project
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}


resource "google_compute_instance_template" "chainlink_node_template" {
  confidential_instance_config {
    enable_confidential_compute = true
  }

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "chainlink-node-template"
    disk_size_gb = 100
    disk_type    = "pd-balanced"
    mode         = "READ_WRITE"
    source_image = "projects/confidential-vm-images/global/images/ubuntu-2004-focal-v20220404"
    type         = "PERSISTENT"
  }

  labels = {
    container-vm = "ubuntu-2004-focal-v20220404"
  }

  machine_type = "n2d-standard-4"

  metadata = {
    enable-oslogin            = "true"
  }

  name = "chainlink-node-template"

  network_interface {
    network            = var.VPC
    subnetwork         = var.Subnet
    subnetwork_project = var.project
  }

  project = var.project
  region  = var.region

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  metadata_startup_script = file("startup.sh")
  
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  tags = ["chainlink-node"]
}