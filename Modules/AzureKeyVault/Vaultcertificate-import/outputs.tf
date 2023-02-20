output "cert_name" {
  description = "Name of the Certificate "
  value       = azurerm_key_vault_certificate.cert.name
}

output "cert_id" {
  description = "The Key Vault Certificate ID."
  value       = azurerm_key_vault_certificate.cert.id
}

output "version_id" {
  description = "The current version of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.cert.version
}

output "certificate_data" {
  description = " The raw Key Vault Certificate data represented as a hexadecimal string."
  value       = azurerm_key_vault_certificate.cert.certificate_data
}
