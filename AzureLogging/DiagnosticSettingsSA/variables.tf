variable "location" {
  type        = string
  description = "The location for the deployment"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group for the deployment"
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

variable "log_analytics_workspace_id" {
  description = "Specifies the id of a log analytics workspace resource."
  type        = string
}

variable "bloblogs" {
  type        = string
  description = "The blob diagnostic settings name"
}

variable "sharelogs" {
  type        = string
  description = "The share diagnostic settings name"
}

variable "storage_account_id" {
  type        = string
  description = "The target storage account id"
}

variable "logs_storage_account_id" {
  type        = string
  description = "The logs storage account id"
}

variable "create_blob_diagnostic" {
  default = true
}

variable "create_share_diagnostic" {
  default = true
}
