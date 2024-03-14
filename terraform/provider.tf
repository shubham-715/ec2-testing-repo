#-----------------------
# Cloud Provider
#-----------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    port = {
            source  = "port-labs/port-labs"
            version = "~> 1.0.0"
        }
  }
}

provider "aws" {
  region     = var.EC2_region
}


