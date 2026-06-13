# The control plane needs a private ipv4 address sadly.
resource "aws_eks_cluster" "main" {
  name = "lightning-${tofu.workspace}"
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }
  role_arn                      = aws_iam_role.eks_cluster.arn
  version                       = local.workspace.kube_version
  bootstrap_self_managed_addons = false
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids              = toset(data.aws_subnets.dualstack_private.ids)
  }
  kubernetes_network_config {
    ip_family = "ipv6"
  }
  # Do I look like I'm made of money?
  upgrade_policy {
    support_type = "STANDARD"
  }
  # The below comment is from the terraform docs!
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_default,
  ]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name lightning-${tofu.workspace}"
  }
}
