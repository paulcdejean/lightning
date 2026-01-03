resource "aws_iam_instance_profile" "bootstrap_nodegroup" {
  name = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  role = aws_iam_role.bootstrap_nodegroup.name
}

resource "aws_iam_role" "bootstrap_nodegroup" {
  name = "lightning-${tofu.workspace}-bootstrap-nodegroup"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# There's 4 types of permissions needed by default according to the docs:
# https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
# 1: "Permissions for the kubelet to describe Amazon EC2 resources in the VPC"
resource "aws_iam_role_policy_attachment" "bootstrap_nodegroup_default_a" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bootstrap_nodegroup.name
}

# 2: "Permissions for the kubelet to use container images from Amazon Elastic Container Registry (Amazon ECR)"
resource "aws_iam_role_policy_attachment" "bootstrap_nodegroup_default_b" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.bootstrap_nodegroup.name
}

# 3: "Permissions for the Amazon EKS Pod Identity Agent
# However we're not using the pod identity agent, because it's dumb.

# 4: "(Optional) If you don’t use IRSA or EKS Pod Identity to give permissions to the VPC CNI pods,
# then you must provide permissions for the VPC CNI on the instance role."
# However there's an issue, that's a lot of access! So we should use IRSA rather than trusting the nodes.
