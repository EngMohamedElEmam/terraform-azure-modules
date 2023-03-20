terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
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

resource "azurerm_monitor_diagnostic_setting" "blob-diagnostic" {
  #count                        = "${var.create_blob_diagnostic ? 0 : 1}"
  name                       = "${lower(var.bloblogs)}${random_string.random.result}"
  target_resource_id         = "${var.storage_account_id}/blobServices/default/"
  storage_account_id         = var.logs_storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "StorageRead"
    enabled  = true
  }

  log {
    category = "StorageWrite"
    enabled  = true
  }

  metric {
    category = "Transaction"
    enabled  = true
    retention_policy {
      days    = 5
      enabled = true
    }
  }
  lifecycle {
    ignore_changes = [log, metric]
    create_before_destroy = true
  }
  tags = local.common_tags
}

resource "azurerm_monitor_diagnostic_setting" "share-diagnostic" {
  #count                        = "${var.create_share_diagnostic ? 0 : 1}"
  name                       = "${lower(var.sharelogs)}${random_string.random.result}"
  target_resource_id         = "${var.storage_account_id}/fileServices/default/"
  storage_account_id         = var.logs_storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "StorageRead"
    enabled  = true
  }

  log {
    category = "StorageWrite"
    enabled  = true
  }

  metric {
    category = "Transaction"
    enabled  = true
    retention_policy {
      days    = 5
      enabled = true
    }
  }
}
