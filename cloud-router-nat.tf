module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project
  name    = "my-cloud-router"
  network = var.VPCName
  region  = var.region

  nats = [{
    name = "my-nat-gateway"
  }]
}