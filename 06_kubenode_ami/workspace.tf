locals {
  workspace = local.workspaces[tofu.workspace]
  workspaces = {
    unstable = {
      state_bucket = "lightning-593941967609-us-east-2-an"
      # This is the AZ where imagebuilder builds the image.
      az = "us-east-2a"
      # Its harder to find this than it should be.
      # I got it from here: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      ecr_credential_helper_path = "amazon-eks/1.34.2/2025-11-13/bin/linux/arm64/ecr-credential-provider"
      kube_version               = "1.34"
      enable_kubelet             = false
    }
  }
}
