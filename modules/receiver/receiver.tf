# TODO - uncomment this provider if you want to run tf commands in the module ie: tf validate
# Dummy provider to appease the TF cli and do 'validate', etc.
#provider "aws" {
#  alias = "sender"
#}

locals {
  access_policy = var.access_policy != "" ? jsonencode(var.access_policy) : data.aws_iam_policy_document.sender_log_destination_access.json
  target_arn    = var.log_destination_target_arn != "" ? var.log_destination_target_arn : aws_kinesis_firehose_delivery_stream.this.arn
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "trust_cwl" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "trust_firehose" {
  statement {
    sid    = "TrustPolicyForFirehose"
    effect = "Allow"
    principals {
      identifiers = ["firehose.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      values   = [var.log_data_destination_account]
      variable = "sts:ExternalId"
    }
  }
}

data "aws_iam_policy_document" "cwl_to_kinesis" {
  statement {
    sid     = "PermissionForCWLogs"
    effect  = "Allow"
    actions = ["kinesis:PutRecord", "firehose:*"]
    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${var.log_data_destination_account}:stream/${var.delivery_stream_name}",
      "arn:aws:firehose:${data.aws_region.current.name}:${var.log_data_destination_account}:*"
    ]
  }
}

# If multiple accounts are sending logs to the destination, each sender account must be listed separately in the policy.
data "aws_iam_policy_document" "sender_log_destination_access" {
  # This policy does not support specifying * as the Principal or the use of the aws:PrincipalOrgId global key.
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = var.log_data_sender_accounts
      type        = "AWS"
    }
    actions   = ["logs:PutSubscriptionFilter"]
    resources = [aws_cloudwatch_log_destination.this.arn]
  }
}

data "aws_iam_policy_document" "firehose_s3" {
  statement {
    sid    = "AllowFirehoseS3"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}",
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
    ]
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
  }

  statement {
    sid       = "Logs"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
  }
}

# The role that lets Kinesis assume it
resource "aws_iam_role" "firehose" {
  name               = "FirehoseS3"
  assume_role_policy = data.aws_iam_policy_document.trust_firehose.json
}

# The destination for the log destination resource type; sends data in the stream to S3
resource "aws_kinesis_firehose_delivery_stream" "this" {
  destination = "extended_s3"
  name        = var.delivery_stream_name

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.this.arn
    role_arn   = aws_iam_role.firehose.arn
  }

  tags = merge({}, var.global_tags)
}

# This IAM role will allow CloudWatch to ship logs to the Kinesis stream
resource "aws_iam_role" "cw_to_kinesis" {
  name               = "CWToKinesis"
  assume_role_policy = data.aws_iam_policy_document.trust_cwl.json
}

# This is the IAM policy for the role that allows log shipping to Kinesis
resource "aws_iam_policy" "cw_to_kinesis" {
  policy = data.aws_iam_policy_document.cwl_to_kinesis.json
}

# This policy allows access to S3
resource "aws_iam_policy" "kinesis_s3" {
  policy = data.aws_iam_policy_document.firehose_s3.json
}

# This attaches the IAM policy, that allows log shipping, to the role used by CloudWatch
resource "aws_iam_role_policy_attachment" "cw_kinesis" {
  policy_arn = aws_iam_policy.cw_to_kinesis.arn
  role       = aws_iam_role.cw_to_kinesis.name
}

# This role is assumed by Kinesis in order to ship logs to S3 per the policy
resource "aws_iam_role_policy_attachment" "kinesis_s3" {
  policy_arn = aws_iam_policy.kinesis_s3.arn
  role       = aws_iam_role.firehose.name
}

# The CloudWatch Logs destination resource in the receiver account. This is the 'shared' component between the senders and receiver accounts.
resource "aws_cloudwatch_log_destination" "this" {
  name       = "CrossAccountKinesis"
  role_arn   = aws_iam_role.cw_to_kinesis.arn
  target_arn = local.target_arn
}

# The CloudWatch logs policy that defines which sender accounts have write access to the CWL destination.
resource "aws_cloudwatch_log_destination_policy" "this" {
  count            = var.create_firehose ? 1 : 0
  access_policy    = local.access_policy
  destination_name = aws_cloudwatch_log_destination.this.name
}

# Shared logs bucket in the reciever account
resource "aws_s3_bucket" "this" {
  bucket_prefix = "firehose-shared-logs"
  acl           = "private"
  tags          = merge({}, var.global_tags)
}
