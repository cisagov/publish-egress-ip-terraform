data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/dns.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "dns_cyber_dhs_gov" {
  backend = "s3"

  config = {
    # There is only one currently-supported bucket and workspace for this remote
    # state (Production), so we must use them.
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-dns-cyber.dhs.gov.tfstate"
    profile        = "cool-terraform-readstate"
    region         = "us-east-1"
  }

  workspace = "production"
}

data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/master.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "terraform" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}
