# Important note!
# It's important to attach cluster admin directly to identity used to log into the console.
# If you instead attach it to a role and have the user assume that role, then they won't have access in the console.
# Yes even if they're a AWS admin.

data "aws_region" "current" {}

data "aws_iam_roles" "admin" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.region}/"
  name_regex  = "AWSReservedSSO_admin_.*"
}

data "aws_iam_role" "admin" {
  name = one(data.aws_iam_roles.admin.names)
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_role.admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_role.admin.arn
  access_scope {
    type = "cluster"
  }
}
