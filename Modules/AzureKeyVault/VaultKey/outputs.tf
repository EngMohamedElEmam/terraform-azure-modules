output "key_name" {
  description = "Name of the Key "
  value       = azurerm_key_vault_key.generated.name
}

output "version" {
  description = "The current version of the Key Vault Key."
  value       = azurerm_key_vault_key.generated.version
}

output "versionless_id" {
  description = "The Base ID of the Key Vault Key."
  value       = azurerm_key_vault_key.generated.versionless_id
}

output "public_key_pem" {
  description = " The PEM encoded public key of this Key Vault Key."
  value       = azurerm_key_vault_key.generated.public_key_pem
}

