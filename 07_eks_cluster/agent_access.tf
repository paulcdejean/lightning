# The lightning-agent IAM user (created in 01_agent/iam.tf) needs Kubernetes
# API access for `tofu plan` in 08_cilium. AmazonEKSAdminViewPolicy grants
# get/list/watch on all resources (read-only — the "Admin" in the name is
# misleading; there are no write verbs). If this isn't sufficient for the
# kubernetes_manifest provider at plan time (which may need patch for dry-run),
# a custom ClusterRole can be layered on later.

data "aws_iam_user" "lightning_agent" {
  user_name = "lightning-agent"
}

resource "aws_eks_access_entry" "lightning_agent" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_user.lightning_agent.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "lightning_agent_view" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  principal_arn = data.aws_iam_user.lightning_agent.arn
  access_scope {
    type = "cluster"
  }
}
