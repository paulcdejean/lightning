resource "aws_eks_access_entry" "kubenode" {
  cluster_name      = data.aws_eks_cluster.lightning.name
  principal_arn     = aws_iam_role.kubenode.arn
  type              = "EC2_LINUX"
}
