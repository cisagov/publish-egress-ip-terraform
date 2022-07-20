# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN in which Terraform is
# authorized.  This is used to calculate the session names for assumed roles.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN from the deployment
# account provider.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "deploy" {
  provider = aws.deploy
}

# ------------------------------------------------------------------------------
# Retrieve the information for all accounts in the organization.  This is used
# to lookup the Users account ID for use in the assume role policy.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "org" {
  provider = aws.organizationsreadonly
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  accounts_to_check = toset(concat([
    for account in data.aws_organizations_organization.org.non_master_accounts :
    account.id
    if length(regexall(var.account_name_regex, account.name)) > 0
  ], var.extraorg_account_ids))

  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  deployment_account_id = data.aws_caller_identity.deploy.account_id
}
