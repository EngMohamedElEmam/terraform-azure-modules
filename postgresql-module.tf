#####################
#PostgreSQL Modules #
#####################

/* # Create resource groups
module "databases-rg" {
  source   = "./ResourceGroup"
  rg_name  = "pharma-databases"
  location = "East US"
} */

# Create storage account to archive PostgreSQL Logs/Diag settings
module "PharmaPostgreSQL-Logs" {
  source                   = "./StorageAccount"
  resource_group_name      = module.databases-rg.rg_name_out
  location                 = "East US"
  account_tier             = "Standard"  #or "Premium"
  account_kind             = "StorageV2" #or "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"
  access_tier              = "Hot"       #or "Cool"
  account_replication_type = "LRS"       #or "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
  base_name                = "pharmapostgrelogs"
  delete_retention_policy  = 365
}

# Create PostgreLogs blob
module "PostgreLogs-Blob" {
  source                            = "./StorageAccount/BlobStorage"
  resource_group_name               = module.databases-rg.rg_name_out
  location                          = "East US"
  storage_account_name              = module.PharmaPostgreSQL-Logs.stg_act_name_out
  storage_account_id                = module.PharmaPostgreSQL-Logs.storage_account_id
  container_name                    = "postgrelogs-logs"
  blob_name                         = "postgrelogs-logsBlob"
  backup_vault_name                 = "postgrelogs-backup-vault"
  backup_policy_blob_name           = "postgrelogs-backup-policy"
  backup_instance_blob_storage_name = "postgrelogs-backup-instance"
  container_access_type             = "private"
  vault_datastore_type              = "VaultStore"
  vault_redundancy                  = "GeoRedundant"
  backup_retention_duration         = "P30D"
}

# Create PostgreLogs share
module "PostgreLogs-Share" {
  source               = "./StorageAccount/ShareStorage"
  resource_group_name  = module.databases-rg.rg_name_out
  location             = "East US"
  storage_account_name = module.PharmaPostgreSQL-Logs.stg_act_name_out
  storage_account_id   = module.PharmaPostgreSQL-Logs.storage_account_id
  share_name           = "postgrelogs-share"
  recovery_vault_name  = "postgrelogs-recovery-vault"
  backup_policy_name   = "postgrelogs-backup-policy"
  share_quota          = 50
}

#Create log analytics workspace for PostgreSql Server Diagnostics settings
module "PharmaPostgreSQL-WorkSpace" {
  source                                    = "./AzureLogging/logs"
  resource_group_name                       = module.databases-rg.rg_name_out
  location                                  = "East US"
  log_analytics                             = "pharmapostgre-workspace"
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_retention_in_days = "90"
}

# Create PostgreSql Server
module "Pharma-PostgreSQL" {
  source                           = "./AzureDatabases/PostgreSQL"
  resource_group_name              = module.databases-rg.rg_name_out
  location                         = "East US"
  postgre_srv_name                 = "pharma-postgre"
  admin_username                   = "postgreadmin"
  admin_password                   = "Postgre@dmin1"
  geo_redundancy_enabled           = true
  ssl_enforcement                  = true
  ssl_minimal_tls_version          = "TLS1_2"
  create_mode                      = "Default"
  sku_name                         = "GP_Gen5_4"
  postgre_version                  = 11
  storage_mb                       = "640000"
  auto_grow_enabled                = true
  backup_retention_days            = "7"
  threat_detection_policy          = true
  threat_policy_log_retention_days = 30
  email_addresses_for_alerts       = ["mohamed.elemam@pharma.org", "mohamed@pharma.org"]
  ad_admin_login_name              = "mohamed.elemam@pharma.org"
  ad_admin_object_id               = data.azuread_user.emam.object_id
  logs_storage_account_id          = module.PharmaPostgreSQL-Logs.storage_account_id
  log_analytics_workspace_id       = module.PharmaPostgreSQL-WorkSpace.workspace_id
  database_name                    = "demo-postgres-db"
  charset                          = "UTF8"
  collation                        = "English_United States.1252"
  public_network_access_enabled    = true
  postgre_firewall_name            = "aksips"
  firewall_rules = {
    access-to-azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    aks-ip = {
      start_ip_address = "40.10.2.4"
      end_ip_address   = "40.10.2.4"
    },
    aks-ip2 = {
      start_ip_address = "40.10.2.5"
      end_ip_address   = "40.10.2.5"
    }
  }
}


#outputs
/* output "databases-rgName" {
  value = module.databases-rg.rg_name_out
}

output "databases-rgLocation" {
  value = module.databases-rg.rg_location_out
}
 */
output "postgre_server_name" {
  value = module.Pharma-PostgreSQL.postgre_server_name
}

output "postgre_server_version" {
  value = module.Pharma-PostgreSQL.postgre_server_version
}

output "postgre_server_username" {
  value = module.Pharma-PostgreSQL.postgre_server_username
}

output "postgre_server_password" {
  value     = module.Pharma-PostgreSQL.postgre_server_password
  sensitive = true
}

output "postgre_server_id" {
  value = module.Pharma-PostgreSQL.postgre_server_id
}

output "firewall_rules" {
  value = module.Pharma-PostgreSQL.firewall_rules
}

output "postgresql_database_id" {
  description = "The ID of the PostgreSQL Database"
  value       = module.Pharma-PostgreSQL.postgresql_database_id
}

output "postgresql_database_name" {
  description = "The Name of the PostgreSQL Database"
  value       = module.Pharma-PostgreSQL.postgresql_database_name
}

output "postgresql_storage_account_logs_name" {
  description = "The Name of the PostgreSQL Database Logs Storage Account Name"
  value       = module.PharmaPostgreSQL-Logs.stg_act_name_out
}
