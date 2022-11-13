terraform {
  required_version = ">= 1.0"
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  # module definitions can be imported from hashicorp/google
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}



