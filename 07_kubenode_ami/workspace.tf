locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      az = "us-east-2a"
      # https://github.com/awslabs/amazon-ecr-credential-helper/releases
      ecr_credential_helper_version = "0.11.0"
    }
  }
}
