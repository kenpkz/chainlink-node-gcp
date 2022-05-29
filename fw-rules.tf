resource "google_compute_firewall" "chainlink_lb_fw" {
  allow {
    protocol = "tcp"
  }

  direction     = "INGRESS"
  name          = "chainlink-lb-fw"
  network       = var.VPC
  priority      = 1000
  project       = var.project
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["chainlink-node"]
}

resource "google_compute_firewall" "allow_iap_chainlink_nodes-fw" {
  allow {
    protocol = "tcp"
  }

  direction     = "INGRESS"
  name          = "allow-iap-chainlink-nodes-fw"
  network       = var.VPC
  priority      = 1000
  project       = var.project
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["chainlink-node"]
}