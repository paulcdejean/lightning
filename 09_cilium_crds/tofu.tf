terraform {
  required_version = "1.11.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

terraform {
  required_version = "1.11.5"
  backend "s3" {
    region               = "us-east-2"
    bucket               = "pauldejean-tofu"
    workspace_key_prefix = "lightning"
    key                  = "08_cilium_crds"
    use_lockfile         = true
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = data.aws_eks_cluster.lightning.arn
}
