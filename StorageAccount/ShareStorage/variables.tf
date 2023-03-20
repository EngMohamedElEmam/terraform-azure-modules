variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "The location for the deployment"
}

variable "environment" {
  type        = string
  default     = "Development"
  description = "Sets the environment for the resources"
}

variable "owner" {
  type        = string
  default     = "Terraform"
  description = "Used in created by tags to identify the owner of the resources."
}

variable "storage_account_id" {
  type        = string
  description = "The storage account id"
}

variable "storage_account_name" {
  type        = string
  description = "The storage account name"
}

variable "share_name" {
  type        = string
  description = "The storage share name"
}

variable "share_quota" {
  type        = number
  description = "The storage share qouta in GB"
}

variable "recovery_vault_name" {
  type        = string
  description = "The recovery vault name"
}

variable "backup_policy_name" {
  type        = string
  description = "The recovery vault backup policy name"
}


