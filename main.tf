locals {
  access_policy = var.access_policy != "" ? jsonencode(var.access_policy) : data.aws_iam_policy_document.sender_log_access.json
  global_tags = {
    Module               = "terraform-aws-cross-account-logs"
    CreatedBy            = "MissionCloud"
    "Mission:Department" = "ConsultingServices"
  }
  target_arn = var.target_arn != "" ? var.target_arn : aws_kinesis_stream.this.arn
}

# Dummy provider to appease the TF cli and do 'validate', etc.
provider "aws" {
  alias = "sender"
}

# The destination Kinesis stream
resource "aws_kinesis_stream" "this" {
  count = var.target_arn != "" ? 0 : 1
  name             = var.destination_name
  shard_count      = var.data_stream_shard_count
  retention_period = var.stream_retention_period
  encryption_type  = var.stream_encryption_type
  kms_key_id       = var.stream_kms_key_id
  tags             = merge(local.global_tags, var.global_tags)
  dynamic "timeouts" {
    for_each = var.stream_timeouts
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

# This IAM role will allow CloudWatch to ship logs to the Kinesis stream
resource "aws_iam_role" "cw_to_kinesis" {
  name               = var.cw_kinesis_role_name
  assume_role_policy = data.aws_iam_policy_document.trust_cwl.json
}

# This is the IAM policy for the role that allows log shipping to Kinesis
resource "aws_iam_policy" "cw_to_kinesis" {
  policy = data.aws_iam_policy_document.cwl.json
}

# This attaches the IAM policy, that allows log shipping, to the role used by CloudWatch
resource "aws_iam_role_policy_attachment" "cw_kinesis" {
  policy_arn = aws_iam_policy.cw_to_kinesis.arn
  role       = aws_iam_role.cw_to_kinesis.name
}

# The CloudWatch Logs destination resource.
resource "aws_cloudwatch_log_destination" "this" {
  name       = var.destination_log_group
  role_arn   = aws_iam_role.cw_to_kinesis.arn
  target_arn = aws_kinesis_stream.this.arn
}

# The CloudWatch logs policy that defines who has write access to the destination.
resource "aws_cloudwatch_log_destination_policy" "this" {
  provider         = aws.sender
  access_policy    = local.access_policy
  destination_name = var.destination_log_group
}

# Subscription filter created in the sending account.
resource "aws_cloudwatch_log_subscription_filter" "this" {
  provider = aws.sender
  destination_arn = local.target_arn
  filter_pattern  = var.log_subscription_filter_pattern
  log_group_name  = var.sender_log_group
  name            = "${data.aws_caller_identity.current.account_id}-${var.destination_name}"
}
