terraform {
  required_version = "1.11.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    toml = {
      source  = "Tobotimus/toml"
      version = "0.3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "1.11.2"
  backend "s3" {
    region               = "us-east-2"
    bucket               = "pauldejean-tofu"
    workspace_key_prefix = "lightning"
    key                  = "02_vpc"
    use_lockfile         = true
  }
}
