terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.2"
    }
  }

  backend "s3" {}
}
