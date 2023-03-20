output "log_analytics" {
  value = resource.azurerm_log_analytics_workspace.workspace.name
}

output "workspace_id" {
  value = resource.azurerm_log_analytics_workspace.workspace.id
}