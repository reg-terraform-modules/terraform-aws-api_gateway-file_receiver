variable "env" {
  description = "Environment dev/prod"
  type    = string
}

variable "project_name" {
  type    = string
}

variable "module_name" {
  type    = string
}

variable "api_description" {
  type    = string
  default = "Standard API for file receiver"
}

variable "iam_api_role_arn" {
  type    = string
}

variable "resource_tags" {
  type    = map(string)
}

variable "api_name" {
  description = "Api name"
  type    = string
}