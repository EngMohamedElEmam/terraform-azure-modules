output "stg_act_name_out" {
  value = resource.azurerm_storage_account.sa.name
}

output "storage_account_id" {
  value = resource.azurerm_storage_account.sa.id
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = resource.azurerm_storage_account.sa.primary_access_key
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = resource.azurerm_storage_account.sa.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  value       = resource.azurerm_storage_account.sa.secondary_connection_string
  sensitive   = true
  description = "Azure Storage Account - Secondary connection string"
}
