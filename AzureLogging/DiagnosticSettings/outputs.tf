output "diagnostic_settings_id" {
  description = "ID of the Diagnostic Settings."
  value       = try(azurerm_monitor_diagnostic_setting.main[0].id, null)
}