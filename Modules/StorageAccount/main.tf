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

resource "azurerm_storage_account" "sa" {
  name                      = "${lower(var.base_name)}${random_string.random.result}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = var.account_tier
  account_kind              = var.account_kind
  access_tier               = var.access_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = true
  blob_properties {
    change_feed_enabled = true
    versioning_enabled  = true
    delete_retention_policy {
      days = var.delete_retention_policy
    }
  }
  tags = local.common_tags
}
