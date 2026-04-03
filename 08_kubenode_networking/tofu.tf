terraform {
  required_version = "1.11.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
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
    bucket               = "pauldejean-tofu"
    workspace_key_prefix = "lightning"
    key                  = "07_kubenode_networking"
    use_lockfile         = true
  }
}
