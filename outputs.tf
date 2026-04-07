output "user_passwords" {
  value     = module.iam_users.user_passwords
  sensitive = true
}