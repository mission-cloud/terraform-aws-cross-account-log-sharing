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
      values   = [var.log_data_destination]
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
      "arn:aws:kinesis:${data.aws_region.current.name}:${var.log_data_destination}:stream/${var.destination_name}",
      "arn:aws:firehose:${data.aws_region.current.name}:${var.log_data_destination}:*"
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
      identifiers = [var.log_data_sender]
      type        = "AWS"
    }
    actions   = ["logs:PutSubscriptionFilter"]
    resources = [aws_cloudwatch_log_destination.this.arn]
  }
}

data "aws_iam_policy_document" "firehose_s3" {
  statement {
    sid       = "AllowFirehoseS3"
    effect    = "Allow"
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
    sid = "Logs"
    effect = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
  }
}
