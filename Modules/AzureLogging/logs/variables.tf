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

variable "log_analytics_workspace_sku" {
  type        = string
  description = "The log analytics SKU name"
}

variable "log_analytics_workspace_retention_in_days" {
  type        = string
  description = "The log analytics retention in days"
}

variable "log_analytics" {
  type        = string
  description = "The log analytics name"
}


