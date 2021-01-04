terraform {
  required_version = ">= 0.14.3"
}

provider "aws" {
  region  = var.region
  profile = "terraforming-appsync"
}
