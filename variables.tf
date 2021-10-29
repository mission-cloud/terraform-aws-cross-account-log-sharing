# For multiple sending accounts, the log group name must be the same - WIP
variable "sender_log_group" {
  description = "The CloudWatch log group associated with the log data sender"
  type        = string
}

variable "log_data_sender" {
  description = "AWS Account number for the data sender."
  type        = string
}

variable "log_data_destination" {
  description = "AWS Account number for the destination."
  type        = string
}

variable "destination_name" {
  description = "The name of the destination you want to create."
  type        = string
  default     = "SharedLogsRecipientStream"
}

variable "target_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS resource that you want to use as the destination of the subscription feed."
  type        = string
  default     = ""
}

variable "create_firehose" {
  description = "Bool flag to create data stream in Kinesis"
  type = bool
  default = false
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

variable "cw_kinesis_role_name" {
  description = "The name of the role that is allowed to send logs to the Kinesis stream"
  type        = string
  default     = "CWToKinesis"
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
