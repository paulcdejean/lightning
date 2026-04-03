terraform {
  required_version = "1.11.5"
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
  required_version = "1.11.5"
  backend "s3" {
    region               = "us-east-2"
    bucket               = local.workspace.state_bucket
    workspace_key_prefix = "lightning"
    key                  = basename(abspath(path.module))
    use_lockfile         = true
  }
}
