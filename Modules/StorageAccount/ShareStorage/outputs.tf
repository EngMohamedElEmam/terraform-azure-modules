output "share_out" {
  value = resource.azurerm_storage_share.share.name
}

output "recovery_vault_out" {
  value = resource.azurerm_backup_container_storage_account.container.recovery_vault_name
}

output "backup_policy_out" {
  value = resource.azurerm_backup_policy_file_share.policy.name
}
