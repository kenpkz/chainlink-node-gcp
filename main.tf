provider "google" {
  region      = var.region
  project = var.project
}

// You can use these to create a new GCP project and default VPC
/* resource "random_id" "project" {
    byte_length = 4
}

resource "google_project" "chainlink_project" {
    name = "chainlink project"
    project_id = "${var.project_prefix}-${random_id.project.hex}"
    billing_account = var.billingaccount
}

resource "google_compute_network" "default" {
  project                 = google_project.chainlink_project.project_id
  name                    = "default"
  auto_create_subnetworks = true
} */
