output "user_passwords" {
  value = {
    for u, p in random_password.passwords :
    u => p.result
  }

  sensitive = true
}