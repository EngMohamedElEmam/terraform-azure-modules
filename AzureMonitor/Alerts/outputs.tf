output "email_alert_action_group_name" {
  value = resource.azurerm_monitor_action_group.email_alert.name
}

output "email_alert_email_receiver" {
  value = resource.azurerm_monitor_action_group.email_alert.email_receiver
}



