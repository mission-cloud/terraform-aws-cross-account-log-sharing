# TODO - uncomment this provider if you want to run tf commands in the module ie: tf validate
# Dummy provider to appease the TF cli and do 'validate', etc.
#provider "aws" {
#  alias = "sender"
#}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Subscription filter created in the sending account.
resource "aws_cloudwatch_log_subscription_filter" "sender" {
  destination_arn = var.log_destination_arn
  filter_pattern  = var.log_subscription_filter_pattern
  log_group_name  = var.sender_log_group
  name            = var.log_subscription_filter_name
}
