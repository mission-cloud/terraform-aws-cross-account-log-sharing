locals {
  log_data_destination = "999999999999"
}
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

provider "aws" {
  alias  = "another-one"
  region = "us-east-1"
  assume_role {
    # sender account mission-cloudops-sandbox
    role_arn         = "arn:aws:iam::810135091555:role/MissionDevOps"
    session_name     = "terraform-aws-cross-account-logs-sender"
    duration_seconds = 3600
  }
}

module "cross_account_logs_111111111111" {
  source = "../.."
  providers = {
    aws        = aws
    aws.sender = aws.sender
  }
  log_data_destination_account = local.log_data_destination
  log_data_sender_account      = "111111111111"
  sender_log_group             = "vpcflowlogs"
}

module "cross_account_logs_222222222222" {
  source = "../.."
  providers = {
    aws        = aws
    aws.sender = aws.another-one
  }
  log_data_destination_account = local.log_data_destination
  log_data_sender_account      = "222222222222"
  sender_log_group             = "vpcflowlogs"
  target_arn                   = module.cross_account_logs_111111111111.target_arn
}
