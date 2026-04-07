variable "region" {
  default = "us-east-1"
}

variable "users" {
  type = set(string)
}

variable "group_name" {
  default = "DevOpsTeam"
}