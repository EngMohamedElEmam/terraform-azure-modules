output "app_insight_name" {
  value = azurerm_application_insights.app1.name
}

output "instrumentation_key" {
  value = azurerm_application_insights.app1.instrumentation_key
}

output "id" {
  value = azurerm_application_insights.app1.id
}

output "app_id" {
  value = azurerm_application_insights.app1.app_id
}

output "app_insights_connection_string" {
  description = "The Connection String for this Application Insights component"
  value       = azurerm_application_insights.app1.connection_string
  sensitive   = true
}
