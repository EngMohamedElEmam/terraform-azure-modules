terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
}

data "azurerm_client_config" "current" {
}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.postgre_srv_name
  }
}


resource "azurerm_postgresql_server" "postgre" {
  name                              = "${lower(var.postgre_srv_name)}${random_string.random.result}"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  administrator_login               = var.admin_username == null ? "postgresadmin" : var.admin_username
  administrator_login_password      = var.admin_password == null ? random_password.main.0.result : var.admin_password
  sku_name                          = var.sku_name
  version                           = var.postgre_version
  storage_mb                        = var.storage_mb
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundancy_enabled
  auto_grow_enabled                 = var.auto_grow_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  ssl_enforcement_enabled           = var.ssl_enforcement
  ssl_minimal_tls_version_enforced  = var.ssl_minimal_tls_version
  infrastructure_encryption_enabled = true
  create_mode                       = var.create_mode
  creation_source_server_id         = var.create_mode != "Default" ? var.creation_source_server_id : null
  restore_point_in_time             = var.create_mode == "PointInTimeRestore" ? var.restore_point_in_time : null

  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy == true ? [1] : []
    content {
      enabled              = var.threat_detection_policy
      disabled_alerts      = var.disabled_alerts
      email_account_admins = var.email_addresses_for_alerts != null ? true : false
      email_addresses      = var.email_addresses_for_alerts
      retention_days       = var.threat_policy_log_retention_days
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
}

resource "azurerm_postgresql_active_directory_administrator" "main" {
  count               = var.ad_admin_login_name != null ? 1 : 0
  server_name         = azurerm_postgresql_server.postgre.name
  resource_group_name = var.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = var.ad_admin_object_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_postgresql_firewall_rule" "firewall" {
  resource_group_name = azurerm_postgresql_server.postgre.resource_group_name
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  server_name         = azurerm_postgresql_server.postgre.name
  start_ip_address    = each.value["start_ip_address"]
  end_ip_address      = each.value["end_ip_address"]

  lifecycle {
    create_before_destroy = true
  }
}

## Create diagnostic setting to keep logs on the log analytics
resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  #count                      = var.log_analytics != null ? 1 : 0
  name                       = lower("extaudit-${var.postgre_srv_name}-diag")
  target_resource_id         = azurerm_postgresql_server.postgre.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.logs_storage_account_id

  dynamic "log" {
    for_each = var.extaudit_diag_logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  lifecycle {
    ignore_changes        = [log, metric]
    create_before_destroy = true
  }
}

# Adding  PostgreSQL Server Database - Default is "true"
resource "azurerm_postgresql_database" "main" {
  name                = "${lower(var.database_name)}${random_string.random.result}"
  resource_group_name = azurerm_postgresql_server.postgre.resource_group_name
  server_name         = azurerm_postgresql_server.postgre.name
  charset             = var.charset
  collation           = var.collation

  lifecycle {
    create_before_destroy = true
  }
}
