variable "region" {
    description = "Region for the GCE and AlloyDB"
    default = "asia-southeast1"
}

/* variable "project_prefix" {
    description = "prefix for created project"
} */

variable "project" {
    description = "GCP Project ID"
}



variable "VPC" {
    description = "VPC"
  
} 

variable "VPCName" {
    description = "VPC disply name"
    default = "default"
}

variable "Subnet" {
    description = "Subnet"
  
}

variable "iapemail" {
    description = "email address displayed on OAuth2 consent, must be an identity in the Cloud Identity"
}

variable "domain" {
    description = "domain for the load balancer"
  
}


/* variable "billingaccount" {
    description = "billing account ID for creating a new project"
} */