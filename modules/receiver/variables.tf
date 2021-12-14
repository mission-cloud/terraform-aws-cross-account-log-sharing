variable "log_data_sender_accounts" {
  description = "The list of authorized accounts to put a subscription filter on the log destination"
  type        = list(any)
  default     = []
}

variable "log_data_destination_account" {
  description = "AWS Account number for the destination."
  type        = string
}

variable "delivery_stream_name" {
  description = "The name of the destination you want to create."
  type        = string
  default     = "SharedLogsRecipientStream"
}

variable "log_destination_target_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS resource that you want to use as the destination of the subscription feed."
  type        = string
  default     = ""
}

variable "create_firehose" {
  description = "Bool flag to create data stream in Kinesis"
  type        = bool
  default     = false
}

variable "access_policy" {
  description = "An IAM policy document (in JSON format, written using IAM policy grammar) that governs the set of users that are allowed to write to your destination."
  type        = string
  default     = ""
}

variable "global_tags" {
  description = "Tags that are applicable to all resources ie: CreatedBy = MissionCloud"
  type        = object({})
  default = {
    CreatedBy            = "MissionCloud"
    "Terraform:Module"   = "terraform-aws-cross-account-log-sharing"
    "Mission:Department" = "ConsultingServices"
  }
}

# Subscription filter pattern to search for and match terms, phrases, or values in log events.
variable "log_subscription_filter_pattern" {
  description = "Subscription filter pattern to search for and match terms, phrases, or values in log events."
  type        = string
  default     = " "
}

variable "log_subscription_filter_name" {
  description = "The name of the sending account's subscription filter for a log group"
  type        = string
  default     = "All - ' '"
}
