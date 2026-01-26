resource "aws_iam_instance_profile" "kubenode" {
  name = "lightning-${tofu.workspace}-kubenode"
  role = aws_iam_role.kubenode.name
}

resource "aws_iam_role" "kubenode" {
  name               = "lightning-${tofu.workspace}-kubenode"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.kubenode_assume_role.json
}

data "aws_iam_policy_document" "kubenode_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_default" {
  role       = aws_iam_role.kubenode.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_pull_ecr" {
  role       = aws_iam_role.kubenode.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_pull_ecr_public" {
  role       = aws_iam_role.kubenode.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  role       = aws_iam_role.kubenode.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
