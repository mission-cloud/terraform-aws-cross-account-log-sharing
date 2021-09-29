provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = ""
    session_name = "terraform-aws-cross-account-logs-receiver"
    duration_seconds = 3600
  }
}

provider "aws" {
  alias = "sender"
  region = "us-east-1"
  assume_role {
    role_arn = ""
    session_name = "terraform-aws-cross-account-logs-sender"
    duration_seconds = 3600
  }
}

module "cross_account_logs" {
  source = "../"
  providers = {
    aws = aws
    aws.sender = aws.sender
  }
  log_data_destination = ""
  log_data_sender = ""
  sender_log_group = ""
}
