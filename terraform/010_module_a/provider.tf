terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["365178742733"]
}