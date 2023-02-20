output "namespace_id" {
  description = "Id of Event Hub Namespace."
  value       = azurerm_eventhub_namespace.namespace.id
}

output "hub_ids" {
  description = "Map of hubs and their ids."
  value       = azurerm_eventhub.eventhub.id
}

output "primary_connection_string" {
  description = "primary_connection_string of hubs"
  value       = azurerm_eventhub_authorization_rule.kafka_rcvr_manage.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "secondary_connection_string of hubs"
  value       = azurerm_eventhub_authorization_rule.kafka_rcvr_manage.secondary_connection_string
  sensitive   = true
}

output "namespace_primary_connection_string" {
  description = "Map of authorization keys with their ids."
  value       = azurerm_eventhub_namespace_authorization_rule.events.primary_connection_string
  sensitive   = true
}

output "namespace_secondary_connection_string" {
  description = "Map of authorization keys with their ids."
  value       = azurerm_eventhub_namespace_authorization_rule.events.secondary_connection_string
  sensitive   = true
}