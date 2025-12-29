resource "aws_iam_instance_profile" "imagebuilder" {
  name = "lightning-${tofu.workspace}-imagebuilder"
  role = aws_iam_role.imagebuilder.name
}

resource "aws_iam_role" "imagebuilder" {
  name               = "lightning-${tofu.workspace}-imagebuilder"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.imagebuilder_assume_role.json
}

data "aws_iam_policy_document" "imagebuilder_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "imagebuilder_required" {
  role       = aws_iam_role.imagebuilder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "imagebuilder_ssm_instance" {
  role       = aws_iam_role.imagebuilder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "logs_bucket_rw" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:*Object",
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.logs_bucket}",
      "arn:aws:s3:::${local.workspace.logs_bucket}/${local.imagebuilder_logs_prefix}/*",
    ]
  }
}

resource "aws_iam_role_policy" "logs_bucket_rw" {
  name   = "logs_bucket_rw"
  role   = aws_iam_role.imagebuilder.id
  policy = data.aws_iam_policy_document.logs_bucket_rw.json
}
