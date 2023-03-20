output "postgre_server_name" {
  value = resource.azurerm_postgresql_server.postgre.name
}

output "postgre_server_id" {
  value = resource.azurerm_postgresql_server.postgre.id
}

output "postgre_server_version" {
  value = resource.azurerm_postgresql_server.postgre.version
}

output "postgre_server_username" {
  value = resource.azurerm_postgresql_server.postgre.administrator_login
}

output "postgre_server_password" {
  value = resource.azurerm_postgresql_server.postgre.administrator_login_password
}

output "firewall_rules" {
  value = resource.azurerm_postgresql_firewall_rule.firewall
}

output "postgresql_database_id" {
  description = "The ID of the PostgreSQL Database"
  value       = resource.azurerm_postgresql_database.main.id
}

output "postgresql_database_name" {
  description = "The Name of the PostgreSQL Database"
  value       = resource.azurerm_postgresql_database.main.name
}

