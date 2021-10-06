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

variable "access_policy" {
  description = "An IAM policy document (in JSON format, written using IAM policy grammar) that governs the set of users that are allowed to write to your destination."
  type        = string
  default     = ""
}

variable "data_stream_shard_count" {
  description = "The number of shards that the stream will use. Amazon has guidelines for specifying the Stream size that should be referenced when creating a Kinesis stream. See [Amazon Kinesis Streams](https://docs.aws.amazon.com/streams/latest/dev/amazon-kinesis-streams.html) for more."
  type        = number
  default     = 1
}

variable "stream_retention_period" {
  description = "Length of time data records are accessible after they are added to the stream. Max is 8760. Min is 24"
  type        = number
  default     = 24
}

variable "stream_encryption_type" {
  description = "The encryption type to use. The only acceptable values are NONE or KMS. The default value is NONE."
  type        = string
  default     = "NONE"
}

variable "stream_kms_key_id" {
  description = "The GUID for the customer-managed KMS key to use for encryption. You can also use a Kinesis-owned master key by specifying the alias alias/aws/kinesis."
  type        = string
  default     = ""
}

variable "stream_timeouts" {
  description = "Nested block argument that allows you to customize how long certain operations are allowed to take before being considered to have failed."
  type        = object({})
  default = {
    create = "10m"
    update = "30m"
    delete = "120m"
  }
}

variable "global_tags" {
  description = "Tags that are applicable to all resources ie: CreatedBy = MissionCloud"
  type        = object({})
  default     = {}
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
