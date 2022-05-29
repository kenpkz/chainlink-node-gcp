resource "google_compute_health_check" "chainlink-autohealing" {
  project = var.project
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds
  tcp_health_check {
    port         = "22"
  }
}

resource "google_iap_brand" "iap_brand" {
  support_email     = var.iapemail
  application_title = "IAP protected Application"
  project           = var.project
}

resource "google_iap_client" "iap_client" {
  display_name = "Chainlink Client"
  brand        =  google_iap_brand.iap_brand.name
} 


resource "google_compute_region_instance_group_manager" "chainlink-mig" {
  project = var.project
  name = "chainlink-mig"
  base_instance_name = "chainlink-node"
  region                     = var.region
  distribution_policy_zones  = ["${var.region}-a", "${var.region}-b"]


  version {
    instance_template  = google_compute_instance_template.chainlink_node_template.id
  }

  target_size  = 2

  named_port {
    name = "chainlink-port"
    port = 6688
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.chainlink-autohealing.id
    initial_delay_sec = 30
  }
}

## Create Load Balancer

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 5.1"
  name    = "chainlink-lb"
  project = var.project
  target_tags = ["chainlink-group"]
  firewall_networks = [var.VPC]
  ssl = true
  https_redirect = true
  managed_ssl_certificate_domains = [var.domain]
  use_ssl_certificates = false

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 6688
      port_name                       = "chainlink-port"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 6688
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = google_compute_region_instance_group_manager.chainlink-mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]

      iap_config = {
        enable               = true
//        oauth2_client_id = ""
//        oauth2_client_secret = ""
        oauth2_client_id     = google_iap_client.iap_client.client_id
        oauth2_client_secret = google_iap_client.iap_client.secret
      }
    }
  }
}