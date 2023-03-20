variable "resource_group_name" {
  type        = string
  description = "The resource group for the deployment"
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

variable "postgre_srv_name" {
  type        = string
  description = "The postgresql server name"
}

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
}

variable "admin_password" {
  type        = string
  description = "The postgresql server admin password"
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "sku_name" {
  type        = string
  description = "The sku name"
}

variable "postgre_version" {
  type        = number
  description = "The postgesql version"
}

variable "storage_mb" {
  type        = number
  description = "The storge size in megabytes"
}

variable "backup_retention_days" {
  type        = string
  description = "The backup retention days"
}

variable "ad_admin_login_name" {
  type        = string
  description = "AD administrator for an Azure database for PostgreSQL"
}

variable "ad_admin_login_name" {
  type        = string
  description = "AD administrator for an Azure database for PostgreSQL"
}

variable "ssl_minimal_tls_version" {
  type        = string
  description = "The minimuam TLS version"
}

variable "ssl_enforcement" {
  type        = bool
  description = "The enforcement enabled"
}

variable "geo_redundancy_enabled" {
  type        = bool
  description = "The geo redundant backup enabled or no"
}

variable "auto_grow_enabled" {
  type        = bool
  description = "The auto growth enabled or no"
}

variable "threat_detection_policy" {
  type        = bool
  description = "The threat_detection_policy enabled or no"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "The public network access enabled or no"
}

variable "postgre_firewall_name" {
  type        = string
  description = "The firewall rule name"
}

variable "firewall_rules" {
  description = "The firewall rule"
}


variable "create_mode" {
  description = " The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default`"
  default     = "Default"
}

variable "creation_source_server_id" {
  description = "For creation modes other than `Default`, the source server ID to use."
  default     = null
}

variable "restore_point_in_time" {
  description = "When `create_mode` is `PointInTimeRestore`, specifies the point in time to restore from `creation_source_server_id`"
  default     = null
}


variable "logs_storage_account_id" {
  type        = string
  description = "The logs storage account id"
}

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Specifies the id of a log analytics workspace resource."
  type        = string
}

variable "extaudit_diag_logs" {
  description = "Database Monitoring Category details for Azure Diagnostic setting"
  default     = ["PostgreSQLLogs", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics"]
}

variable "enable_threat_detection_policy" {
  description = "Threat detection policy configuration, known in the API as Server Security Alerts Policy"
  default     = false
}

variable "email_addresses_for_alerts" {
  description = "A list of email addresses which alerts should be sent to."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "threat_policy_log_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
  default     = "30"
}

variable "database_name" {
  description = "Specifies the database name"
  type        = string
}

variable "charset" {
  description = "Specifies the charset"
  type        = string
}

variable "collation" {
  description = "Specifies the collection"
  type        = string
}
