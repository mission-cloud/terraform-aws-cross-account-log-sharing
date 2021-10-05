locals {
  access_policy = var.access_policy != "" ? jsonencode(var.access_policy) : data.aws_iam_policy_document.sender_log_destination_access.json
  global_tags = {
    Module               = "terraform-aws-cross-account-logs"
    CreatedBy            = "MissionCloud"
    "Mission:Department" = "ConsultingServices"
  }
  target_arn = var.target_arn != "" ? var.target_arn : aws_kinesis_stream.this[0].arn
}

# Dummy provider to appease the TF cli and do 'validate', etc.
provider "aws" {
  alias = "sender"
}

#######################################
## Data Stream
#######################################
resource "aws_kinesis_firehose_delivery_stream" "this" {
  destination = ""
  name        = ""
}
# The destination Kinesis stream
resource "aws_kinesis_stream" "this" {
  count            = var.target_arn != "" ? 0 : 1
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
  policy = data.aws_iam_policy_document.cwl_to_kinesis.json
}

# This attaches the IAM policy, that allows log shipping, to the role used by CloudWatch
resource "aws_iam_role_policy_attachment" "cw_kinesis" {
  policy_arn = aws_iam_policy.cw_to_kinesis.arn
  role       = aws_iam_role.cw_to_kinesis.name
}

# The CloudWatch Logs destination resource in the receiver account. This is the 'shared' component between the sender and receiver accounts.
resource "aws_cloudwatch_log_destination" "this" {
  name       = "CrossAccountKinesis"
  role_arn   = aws_iam_role.cw_to_kinesis.arn
  target_arn = local.target_arn
}

# The CloudWatch logs policy that defines which sender accounts have write access to the CWL destination.
resource "aws_cloudwatch_log_destination_policy" "this" {
  access_policy    = local.access_policy
  destination_name = aws_cloudwatch_log_destination.this.name
}
#######################################
## Data producers
#######################################
# Subscription filter created in the sending account.
resource "aws_cloudwatch_log_subscription_filter" "sender" {
  provider        = aws.sender
  destination_arn = aws_cloudwatch_log_destination.this.arn
  filter_pattern  = var.log_subscription_filter_pattern
  log_group_name  = var.sender_log_group
  name            = var.log_subscription_filter_name
}

#######################################
## Data Consumers
#######################################
resource "" "" {}
