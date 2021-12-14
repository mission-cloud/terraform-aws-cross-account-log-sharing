# For multiple sending accounts, the log group name must be the same - WIP
variable "sender_log_group" {
  description = "The CloudWatch log group associated with the log data sender"
  type        = string
}

variable "log_destination_arn" {
  description = "The ARN of the log destination"
  type        = string
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
