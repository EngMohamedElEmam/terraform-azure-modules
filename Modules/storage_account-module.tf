/* ##########################
#Storage Account Modules #
##########################

# Create Pharma storage account
module "PharmaSA" {
  source                   = "./StorageAccount"
  resource_group_name      = module.storage-rg.rg_name_out
  location                 = "East US"
  account_tier             = "Standard"  #or "Premium"
  account_kind             = "StorageV2" #or "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"
  access_tier              = "Hot"       #or "Cool"
  account_replication_type = "GRS"       #or "LRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
  base_name                = "storagepharma"
  delete_retention_policy  = 365
}

# Create Pharma storage account blob
module "PharmaSA-Blob" {
  source                            = "./StorageAccount/BlobStorage"
  resource_group_name               = module.storage-rg.rg_name_out
  location                          = "East US"
  storage_account_name              = module.PharmaSA.stg_act_name_out
  storage_account_id                = module.PharmaSA.storage_account_id
  container_name                    = "PharmaSABlob"
  blob_name                         = "PharmaSABlob"
  backup_vault_name                 = "PharmaSA-backup-vault"
  backup_policy_blob_name           = "PharmaSA-backup-policy"
  backup_instance_blob_storage_name = "PharmaSA-backup-instance"
  container_access_type             = "private"
  vault_datastore_type              = "VaultStore"
  vault_redundancy                  = "GeoRedundant"
  backup_retention_duration         = "P30D"
}

# Create Pharma storage account share
module "PharmaSA-Share" {
  source               = "./StorageAccount/ShareStorage"
  resource_group_name  = module.storage-rg.rg_name_out
  location             = "East US"
  storage_account_name = module.PharmaSA.stg_act_name_out
  storage_account_id   = module.PharmaSA.storage_account_id
  share_name           = "PharmaSAshare"
  recovery_vault_name  = "PharmaSA-recovery-vault"
  backup_policy_name   = "PharmaSA-backup-policy"
  share_quota          = 50
}

# Create Pharma storage account to archive logs for PharmaSA
module "PharmaSA-Logs" {
  source                   = "./StorageAccount"
  resource_group_name      = module.logs-rg.rg_name_out
  location                 = "East US"
  account_tier             = "Standard"  #or "Premium"
  account_kind             = "StorageV2" #or "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"
  access_tier              = "Hot"       #or "Cool"
  account_replication_type = "GRS"       #or "LRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
  base_name                = "pharmasalogs"
  delete_retention_policy  = 365
}

# Create PharmaSA-Logs blob
module "PharmaSALogs-Blob" {
  source                            = "./StorageAccount/BlobStorage"
  resource_group_name               = module.logs-rg.rg_name_out
  location                          = "East US"
  storage_account_name              = module.PharmaSA-Logs.stg_act_name_out
  storage_account_id                = module.PharmaSA-Logs.storage_account_id
  container_name                    = "pharmasalogs"
  blob_name                         = "pharmasalogsogsBlob"
  backup_vault_name                 = "pharmasalogs-backup-vault"
  backup_policy_blob_name           = "pharmasalogs-backup-policy"
  backup_instance_blob_storage_name = "pharmasalogs-backup-instance"
  container_access_type             = "private"
  vault_datastore_type              = "VaultStore"
  vault_redundancy                  = "GeoRedundant"
  backup_retention_duration         = "P30D"
}

# Create PharmaSA-Logs share
module "PharmaSALogs-Share" {
  source               = "./StorageAccount/ShareStorage"
  resource_group_name  = module.logs-rg.rg_name_out
  location             = "East US"
  storage_account_name = module.PharmaSA-Logs.stg_act_name_out
  storage_account_id   = module.PharmaSA-Logs.storage_account_id
  share_name           = "pharmasalogsshare"
  recovery_vault_name  = "pharmasalogsshare-recovery-vault"
  backup_policy_name   = "pharmasalogsshare-backup-policy"
  share_quota          = 50
}

# Create Log analytics workspace for Diagnostic Settings storage account
module "PharmaSA-LogWorkSpace" {
  source                                    = "./AzureLogging/logs"
  resource_group_name                       = module.logs-rg.rg_name_out
  location                                  = "East US"
  log_analytics                             = "pharmasa-workspace"
  log_analytics_workspace_sku               = "Standalone"
  log_analytics_workspace_retention_in_days = "90"
}

# Create Diagnostic Settings for storage account
module "PharmaSA-DiagnosticSettings" {
  source                     = "./AzureLogging/DiagnosticSettingsSA"
  resource_group_name        = module.logs-rg.rg_name_out
  location                   = "East US"
  storage_account_id         = module.PharmaSA.storage_account_id #target
  log_analytics_workspace_id = module.PharmaSA-LogWorkSpace.workspace_id
  bloblogs                   = "pharmasalogsogsBlob"
  sharelogs                  = "pharmasalogsshare"
  logs_storage_account_id    = module.PharmaSA-Logs.storage_account_id #to archive logs
}


#output
output "storage-rgName" {
  value = module.storage-rg.rg_name_out
}

output "storage-rgLocation" {
  value = module.storage-rg.rg_location_out
}


output "Storage_Account_Name" {
  value = module.PharmaSA.stg_act_name_out
}

output "Continer_Name" {
  value = module.PharmaSA-Blob.container_out
}

output "Blob_Name" {
  value = module.PharmaSA-Blob.blob_out
}

output "Share_Name" {
  value = module.PharmaSA-Share.share_out
}

output "Recovery_Vault_Name" {
  value = module.PharmaSA-Share.recovery_vault_out
}

output "Backup_Policy_Name" {
  value = module.PharmaSA-Share.backup_policy_out
}

output "Container_Backup_Vault_Name" {
  value = module.PharmaSA-Blob.backup_vault_out
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = module.PharmaSA.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = module.PharmaSA.secondary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = module.PharmaSA.primary_access_key
  sensitive   = true
}
 */
