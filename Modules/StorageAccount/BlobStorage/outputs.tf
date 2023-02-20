output "container_out" {
  value = resource.azurerm_storage_container.storage_container.name
}

output "containerid_out" {
  value = resource.azurerm_storage_container.storage_container.id
}

output "blob_out" {
  value = resource.azurerm_storage_blob.blob.name
}

output "backup_vault_out" {
  value = resource.azurerm_data_protection_backup_vault.protection.name
}

output "azurerm_storage_management_policy" {
  value = resource.azurerm_storage_management_policy.policy.rule
}