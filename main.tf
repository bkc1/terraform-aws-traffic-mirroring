# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  version = "~> 3.0"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

terraform {
  required_version = ">= 0.13.0"
}

# This will fetch our account_id, no need to hard code it
#data "aws_caller_identity" "current" {}
