output "log_analytics_bloblog" {
  value = resource.azurerm_monitor_diagnostic_setting.blob-diagnostic.log
}

output "log_analytics_sharelog" {
  value = resource.azurerm_monitor_diagnostic_setting.share-diagnostic.log
}