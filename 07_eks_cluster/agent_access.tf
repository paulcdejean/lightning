# The lightning-agent IAM user (created in 01_agent/iam.tf) needs Kubernetes
# API access for `tofu plan` in 08_cilium, which uses the kubernetes provider
# to apply CRD manifests.  Without an access entry, EKS rejects the IAM user's
# token with "the server has asked for the client to provide credentials".

data "aws_iam_user" "lightning_agent" {
  user_name = "lightning-agent"
}

resource "aws_eks_access_entry" "lightning_agent" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_user.lightning_agent.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "lightning_agent" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_user.lightning_agent.arn
  access_scope {
    type = "cluster"
  }
}
