terraform {
  required_version = "1.11.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

terraform {
  required_version = "1.11.2"
  backend "s3" {
    region               = "us-east-2"
    bucket               = "pauldejean-tofu"
    workspace_key_prefix = "lightning"
    key                  = "09_cilium_nonodes"
    use_lockfile         = true
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
    context     = data.aws_eks_cluster.lightning.arn
  }
}