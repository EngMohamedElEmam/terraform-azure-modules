variable "resource_group_name" {
  type        = string
  description = "The resource group for the deployment"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Sets the environment for the resources"
}

variable "owner" {
  type        = string
  default     = "Terraform"
  description = "Used in created by tags to identify the owner of the resources."
}

variable "email_alert" {
  type        = string
  description = "The action group alert email name"
}

variable "short_name" {
  type        = string
  description = "The action group alert email short name"
}

variable "email_address" {
  type        = string
  description = "The action group alert email address"
}

