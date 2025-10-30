data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "example_policy" {
  statement {
    sid    = "ListBuckets"
    effect = "Allow"

    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::/example"
    ]
  }

  statement {
    sid    = "WritePermissionsOnBucket"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::/example/*"
    ]
  }

  statement {
    sid    = "AccessToTheKey"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:GenerateDataKeyPairWithoutPlaintext",
      "kms:GenerateRandom",
      "kms:GetKeyPolicy"
    ]

    resources = ["*"]
  }

  # data "aws_vpc" "this" {
  #   filter {
  #     name   = "tag:Name"
  #     values = ["${local.common_name_prefix}"]
  #   }
  # }

  # data "aws_availability_zones" "available" {
  #   state = "available"
  # }

  # data "aws_subnets" "private" {
  #   filter {
  #     name   = "vpc-id"
  #     values = [data.aws_vpc.this.id]
  #   }

  #   tags = {
  #     Name = "${local.common_name_prefix}-private*"
  #   }
  # }

  # data "aws_subnets" "public" {
  #   filter {
  #     name   = "vpc-id"
  #     values = [data.aws_vpc.this.id]
  #   }

  #   tags = {
  #     Name = "${local.common_name_prefix}-public*"
  #   }
  # }

  # data "aws_subnets" "database" {
  #   filter {
  #     name   = "vpc-id"
  #     values = [data.aws_vpc.this.id]
  #   }

  #   tags = {
  #     Name = "${local.common_name_prefix}-db*"
  #   }
  # }

  # data "aws_ami" "amazon_linux" {
  #   most_recent = true
  #   owners      = ["amazon"]
  #   name_regex  = "^al2023-ami-2023.*-x86_64"
  # }
}