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

variable "app_insight_name" {
  type        = string
  description = "The app_insight_name"
}

variable "application_type" {
  type        = string
  description = "Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created."
}

variable "daily_data_cap_in_gb" {
  type        = number
  description = "Specifies the Application Insights component daily data volume cap in GB."
}

variable "daily_data_cap_notification_disabled" {
  type        = bool
  default     = false
  description = "Specifies if a notification email will be send when the daily data volume cap is met. Defaults to false"
}

variable "retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the retention period in days. Possible values are 30, 60, 90, 120, 180, 270, 365, 550 or 730. Defaults to 90."
}

variable "sampling_percentage" {
  type        = string
  default     = 100
  description = "Specifies the percentage of the data produced by the monitored application that is sampled for Application Insights telemetry. Defaults to 100."
}

variable "disable_ip_masking" {
  type        = string
  default     = false
  description = "By default the real client ip is masked as 0.0.0.0 in the logs. Use this argument to disable masking and log the real client ip. Defaults to false."
}

variable "log_analytics_workspace_resource_id" {
  description = "Specifies the id of a log analytics workspace resource."
  type        = string
  default     = null
}
