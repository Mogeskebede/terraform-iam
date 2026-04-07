module "password_policy" {
  source = "./modules/iam-password-policy"

  min_length = 12
}

module "iam_security" {
  source = "./modules/iam-security"

  policy_name = "dev-enforce-mfa"
}

module "iam_group" {
  source = "./modules/iam-group"

  group_name = var.group_name

  policy_arns = {
    readonly  = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    poweruser = "arn:aws:iam::aws:policy/PowerUserAccess"
    mfa       = module.iam_security.mfa_policy_arn
  }
}

module "iam_users" {
  source = "./modules/iam-users"

  users      = var.users
  group_name = module.iam_group.group_name

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}