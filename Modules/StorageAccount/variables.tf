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

variable "base_name" {
  type        = string
  description = "The storage accuont base name"
}

variable "account_tier" {
  type        = string
  description = "The storage account tier"
}

variable "access_tier" {
  type        = string
  description = "The storage access tier"
}

variable "account_kind" {
  type        = string
  description = "The storage account kind"
}

variable "account_replication_type" {
  type        = string
  description = "The storage account account replication type"
}

variable "delete_retention_policy" {
  type        = number
  description = "The delete_retention_policy in days"
}


