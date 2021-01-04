## Global
variable "aws_account_id" {
  description = "Account to build resources in."
  default     = "999783095318"
}

variable "account_name" {
  description = "Name of account."
  default     = "terraforming-appsync"
}

variable "region" {
  default = "us-west-2"
}
