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

## Create storage account file share
resource "azurerm_storage_share" "share" {
  name                 = "${lower(var.share_name)}${random_string.random.result}"
  storage_account_name = var.storage_account_name
  quota                = var.share_quota

  lifecycle {
    create_before_destroy = true
  }
}

## Create recovery vault 
resource "azurerm_recovery_services_vault" "vault" {
  #count               = "${var.create_recovery_vault ? 0 : 1}"
  name                = "${lower(var.recovery_vault_name)}${random_string.random.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true

  lifecycle {
    create_before_destroy = true
  }
}

## Associate storage account to the recovery vault
resource "azurerm_backup_container_storage_account" "container" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  storage_account_id  = var.storage_account_id
  depends_on          = [azurerm_recovery_services_vault.vault]

  lifecycle {
    create_before_destroy = true
  }
}

## Create backup policy for file share
resource "azurerm_backup_policy_file_share" "policy" {
  name                = "${lower(var.backup_policy_name)}${random_string.random.result}"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 7
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 7
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [azurerm_backup_container_storage_account.container, azurerm_recovery_services_vault.vault]
}

## Associate backup policy to file share
resource "azurerm_backup_protected_file_share" "share" {
  resource_group_name       = var.resource_group_name
  recovery_vault_name       = azurerm_recovery_services_vault.vault.name
  source_storage_account_id = var.storage_account_id
  source_file_share_name    = azurerm_storage_share.share.name
  backup_policy_id          = azurerm_backup_policy_file_share.policy.id

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [azurerm_storage_share.share, azurerm_backup_policy_file_share.policy, azurerm_backup_container_storage_account.container, azurerm_recovery_services_vault.vault]
}
