# TODO - uncomment this provider if you want to run tf commands in the module ie: tf validate
# Dummy provider to appease the TF cli and do 'validate', etc.
#provider "aws" {
#  alias = "sender"
#}
locals {
  access_policy = var.access_policy != "" ? jsonencode(var.access_policy) : data.aws_iam_policy_document.sender_log_destination_access.json
  target_arn    = var.target_arn != "" ? var.target_arn : aws_kinesis_firehose_delivery_stream.this[0].arn
}

#######################################
## Data Stream
#######################################
# The role that lets Kinesis assume it
resource "aws_iam_role" "firehose" {
  name               = "FirehoseS3"
  assume_role_policy = data.aws_iam_policy_document.trust_firehose.json
}

# The destination for the log destination resource type; sends data in the stream to S3
resource "aws_kinesis_firehose_delivery_stream" "this" {
  count       = var.target_arn != "" ? 0 : 1
  destination = "extended_s3"
  name        = var.destination_name

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.this.arn
    role_arn   = aws_iam_role.firehose.arn
  }

  tags = merge({}, var.global_tags)
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
# Shared logs bucket in the reciever account
resource "aws_s3_bucket" "this" {
  bucket_prefix = "firehose-shared-logs"
  acl           = "private"
  tags          = merge({}, var.global_tags)
}
