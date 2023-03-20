####################
#Event Hub Modules #
####################

# Create resource groups
module "logs-rg" {
  source   = "./ResourceGroup"
  rg_name  = "pharma-logs"
  location = "East US"
}

#Create Event Hub
module "Pharma-EventHub" {
  source                             = "./AzureLogging/EventHub"
  resource_group_name                = module.logs-rg.rg_name_out
  location                           = "East US"
  eventhub_namespace_name            = "pharma-eventhub-namespace1"
  namespace_sku                      = "Standard"
  zone_redundant                     = false
  eventhub_name                      = "pharma-eventhub1"
  eventhub_status                    = "Active"
  partition_count                    = 4
  message_retention                  = 1
  namespace_capacity                 = 1
  auto_inflate_enabled               = true
  namespace_maximum_throughput_units = 10
  capture                            = true
  encoding                           = "Avro"
  event_blob_container_name          = module.PharmaEvetHub-BlobCapture.container_out
  event_storage_account_id           = module.PharmaEvetHub-Capture.storage_account_id
  log_analytics_workspace_id         = module.PharmaEventHub-LogWorkSpace.workspace_id
  eventhub_diagnostics               = "Pharmaeventhub-diag"
  network_rulesets = {
    default_action                 = "Allow" #"Deny"
    trusted_service_access_enabled = true
    #virtual_network_rule          = ["40.10.2.4", "40.10.2.5", "102.190.233.109"]
    #ip_rule                       = ["40.10.2.4", "40.10.2.5", "102.190.233.109"]
  }
  #logs_storage_account_id           = 
}

# Create Log analytics workspace for Diagnostic Settings Event Hub
module "PharmaEventHub-LogWorkSpace" {
  source                                    = "./AzureLogging/logs"
  resource_group_name                       = module.logs-rg.rg_name_out
  location                                  = "East US"
  log_analytics                             = "pharmaevethub-workspace"
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_retention_in_days = "90"
}

# Create storage account to archive or keep/capture the PharmaEvetHub data 
module "PharmaEvetHub-Capture" {
  source                   = "./StorageAccount"
  resource_group_name      = module.logs-rg.rg_name_out
  location                 = "East US"
  account_tier             = "Standard"  #or "Premium"
  account_kind             = "StorageV2" #or "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"
  access_tier              = "Hot"       #or "Cool"
  account_replication_type = "GRS"       #or "LRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
  base_name                = "pharmaevethubcapture"
  delete_retention_policy  = 365
}

# Create PharmaEvetHub capture blob
module "PharmaEvetHub-BlobCapture" {
  source                            = "./StorageAccount/BlobStorage"
  resource_group_name               = module.logs-rg.rg_name_out
  location                          = "East US"
  storage_account_name              = module.PharmaEvetHub-Capture.stg_act_name_out
  storage_account_id                = module.PharmaEvetHub-Capture.storage_account_id
  container_name                    = "pharmahubblobcapture"
  blob_name                         = "pharmahubblobcapture"
  backup_vault_name                 = "pharmahubblobcapture-backup-vault"
  backup_policy_blob_name           = "pharmaevethubblobcapture-policy"
  backup_instance_blob_storage_name = "pharmaevethubblobcapture"
  container_access_type             = "private"
  vault_datastore_type              = "VaultStore"
  vault_redundancy                  = "GeoRedundant"
  backup_retention_duration         = "P30D"
}

# Create PharmaEvetHub capture share
module "PharmaEvetHub-ShareCapture" {
  source               = "./StorageAccount/ShareStorage"
  resource_group_name  = module.logs-rg.rg_name_out
  location             = "East US"
  storage_account_name = module.PharmaEvetHub-Capture.stg_act_name_out
  storage_account_id   = module.PharmaEvetHub-Capture.storage_account_id
  share_name           = "pharmaevethubcapture-share"
  recovery_vault_name  = "pharmaevethubsharecapture-recovery-vault"
  backup_policy_name   = "pharmaevethubcapture-backup-policy"
  share_quota          = 50
}


#outputs
output "logs-rgName" {
  value = module.logs-rg.rg_name_out
}

output "logs-rgLocation" {
  value = module.logs-rg.rg_location_out
}

output "eventhub_namespace_id" {
  description = "Id of Event Hub Namespace."
  value       = module.Pharma-EventHub.namespace_id
}

output "eventhub_ids" {
  description = "Map of hubs and their ids."
  value       = module.Pharma-EventHub.hub_ids
}

output "eventhub_primary_connection_string" {
  description = "primary_connection_string of hubs"
  value       = module.Pharma-EventHub.primary_connection_string
  sensitive   = true
}

output "eventhub_secondary_connection_string" {
  description = "secondary_connection_string of hubs"
  value       = module.Pharma-EventHub.secondary_connection_string
  sensitive   = true
}

output "namespace_primary_connection_string" {
  description = "primary_connection_string of namespace"
  value       = module.Pharma-EventHub.primary_connection_string
  sensitive   = true
}

output "namespace_secondary_connection_string" {
  description = "namespace_secondary_connection_string"
  value       = module.Pharma-EventHub.secondary_connection_string
  sensitive   = true
}
