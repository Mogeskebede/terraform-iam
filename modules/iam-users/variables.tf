variable "users" {
  type = set(string)
}

variable "group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}