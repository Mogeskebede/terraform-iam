resource "aws_iam_user" "users" {
  for_each = var.users

  name          = each.value
  force_destroy = true

  tags = var.tags
}

resource "random_password" "passwords" {
  for_each = var.users

  length  = 16
  special = true
}

resource "aws_iam_user_login_profile" "login" {
  for_each = var.users

  user                    = aws_iam_user.users[each.value].name
  password_reset_required = true
}

resource "aws_iam_user_group_membership" "membership" {
  for_each = var.users

  user   = aws_iam_user.users[each.value].name
  groups = [var.group_name]
}