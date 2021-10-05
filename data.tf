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

data "aws_iam_policy_document" "cwl_to_kinesis" {
  statement {
    sid       = "PermissionForCWLogs"
    effect    = "Allow"
    actions   = ["kinesis:PutRecord"]
    resources = [local.target_arn]
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
