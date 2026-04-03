terraform {
  required_version = "1.11.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "1.11.5"
  backend "s3" {
    region               = "us-east-2"
    bucket               = "lightning-593941967609-us-east-2-an
    workspace_key_prefix = "lightning"
    key                  = basename(abspath(path.module))
    use_lockfile         = true
  }
}
