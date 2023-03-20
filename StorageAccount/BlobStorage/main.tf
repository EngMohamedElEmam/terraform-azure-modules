terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
}

## Create storage account container
resource "azurerm_storage_container" "storage_container" {
  name                  = "${lower(var.container_name)}${random_string.random.result}"
  storage_account_name  = var.storage_account_name
  container_access_type = var.container_access_type

  lifecycle {
    create_before_destroy = true
  }
}

## Create storage account blob
resource "azurerm_storage_blob" "blob" {
  name                   = "${lower(var.blob_name)}${random_string.random.result}"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"

  lifecycle {
    create_before_destroy = true
  }
}

## Create storage account lifecycle management for container/blob storage
resource "azurerm_storage_management_policy" "policy" {
  storage_account_id = var.storage_account_id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      #prefix_match = ["containerpharma/terra"]
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
  rule {
    name    = "rule2"
    enabled = true
    filters {
      #  prefix_match = ["containerpharma/terra", "container2/prefix2"]
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 11
        tier_to_archive_after_days_since_modification_greater_than = 51
        delete_after_days_since_modification_greater_than          = 101
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation = 90
        change_tier_to_cool_after_days_since_creation    = 23
        delete_after_days_since_creation_greater_than    = 31
      }
      version {
        change_tier_to_archive_after_days_since_creation = 9
        change_tier_to_cool_after_days_since_creation    = 90
        delete_after_days_since_creation                 = 3
      }
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

## Create data protection backup for blob storage
resource "azurerm_data_protection_backup_vault" "protection" {
  name                = "${lower(var.backup_vault_name)}${random_string.random.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = var.vault_datastore_type
  redundancy          = var.vault_redundancy
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    create_before_destroy = true
  }
}

## Create role assignment for the managed identity of the data protection backup
resource "azurerm_role_assignment" "role" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.protection.identity[0].principal_id
  lifecycle {
    create_before_destroy = true
  }
}

## Create the policy for the data protection backup
resource "azurerm_data_protection_backup_policy_blob_storage" "policy" {
  name               = "${lower(var.backup_policy_blob_name)}${random_string.random.result}"
  vault_id           = azurerm_data_protection_backup_vault.protection.id
  retention_duration = var.backup_retention_duration
  lifecycle {
    create_before_destroy = true
  }
}

## Associate backup policy to blob storage
resource "azurerm_data_protection_backup_instance_blob_storage" "policy" {
  name               = "${lower(var.backup_instance_blob_storage_name)}${random_string.random.result}"
  vault_id           = azurerm_data_protection_backup_vault.protection.id
  location           = var.location
  storage_account_id = var.storage_account_id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.policy.id

  lifecycle {
    create_before_destroy = false
  }
  depends_on = [azurerm_role_assignment.role, azurerm_data_protection_backup_vault.protection, azurerm_data_protection_backup_policy_blob_storage.policy]
}
