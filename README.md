# terraform-aws-cross-account-logs

## What it does
This is a cross account module that allows CloudWatch logs to be shipped
from a sender account(s) to a receiver account via a log subscription filter
to a Kinesis Data Firehose to an S3 bucket.

### Subscribing other accounts  
1. Add a provider with an alias  
```hcl
provider "aws" {
  alias  = "sender"
  region = "us-east-1"
  assume_role {
    role_arn         = "arn:aws:iam::123456789012:role/RoleName"
    session_name     = "terraform-aws-cross-account-logs-sender"
    duration_seconds = 3600
  }
}
```
2. Update the policy `aws_iam_policy_document.sender_log_destination_access` to include the new
sender account  
3. Add a new resource `aws_cloudwatch_log_subscription_filter.senderx` under the Data Producers section

## [Module Documentation](MODULE.md)

## Examples 
[Basic](examples/basic/main.tf)
[Multiple Senders](examples/multi-senders/main.tf)
