terraform {
  required_version = "1.11.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
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
    bucket               = "lightning-593941967609-us-east-2-an"
    workspace_key_prefix = "lightning"
    key                  = basename(abspath(path.module))
    use_lockfile         = true
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = data.aws_eks_cluster.lightning.arn
}
