terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.15.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    region               = "us-east-2"
    bucket               = "pauldejean-tofu"
    workspace_key_prefix = "lightning"
    key                  = "01_ipspace"
    use_lockfile         = true
  }
}
