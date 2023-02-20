output "uai_id" {
  description = "uai_id"
  value       = azurerm_user_assigned_identity.uai.id
}

output "principal_id" {
  description = "principal_id"
  value       = azurerm_user_assigned_identity.uai.principal_id
}