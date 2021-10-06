terraform {
  backend "local" {}
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    # destination account mission-devops-sandbox
    role_arn         = "arn:aws:iam::465743759656:role/MissionAdministrator"
    session_name     = "terraform-aws-cross-account-logs-receiver"
    duration_seconds = 3600
  }
}

provider "aws" {
  alias  = "sender"
  region = "us-east-1"
  assume_role {
    # sender account mission-cloudops-sandbox
    role_arn         = "arn:aws:iam::810135091555:role/MissionDevOps"
    session_name     = "terraform-aws-cross-account-logs-sender"
    duration_seconds = 3600
  }
}

module "cross_account_logs" {
  source = "../"
  providers = {
    aws        = aws
    aws.sender = aws.sender
  }
  log_data_destination = "465743759656"
  log_data_sender      = "810135091555"
  sender_log_group     = "/mission/vpc/cb-tf-test-flowlogs"
}
