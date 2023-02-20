output "secret_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault_secret.secret.name
}

output "vault_secret" {
  description = "Uri of the Key Vault"
  value       = azurerm_key_vault_secret.secret.value
}



