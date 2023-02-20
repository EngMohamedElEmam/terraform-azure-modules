terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }

  collections = flatten([
    for db_key, db in var.databases : [
      for col in db.collections : {
        name           = col.name
        database       = db_key
        shard_key      = col.shard_key
        throughput     = col.throughput
        max_throughput = col.max_throughput
      }
    ]
  ])

  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "Microsoft.OperationalInsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = var.diagnostics.metrics
    log                = var.diagnostics.logs
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_cosmosdb_account" "main" {
  name                 = "${lower(var.name)}${random_string.random.result}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  offer_type           = "Standard"
  kind                 = var.kind
  mongo_server_version = var.mongo_server_version

  enable_free_tier                      = var.enable_free_tier
  enable_automatic_failover             = var.enable_automatic_failover
  public_network_access_enabled         = var.public_network_access
  network_acl_bypass_for_azure_services = var.bypass_for_azure_services
  network_acl_bypass_ids                = var.bypass_resources_ids
  ip_range_filter                       = join(",", var.ip_range_filter)
  is_virtual_network_filter_enabled     = var.virtual_network_enabled

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rule == null ? [] : [var.virtual_network_rule]
    iterator = rule
    content {
      id = rule.value.vnet_subnet_ids
    }
  }

  dynamic "capacity" {
    for_each = var.capacity == null ? [] : [var.capacity]
    iterator = rule
    content {
      total_throughput_limit = rule.value.total_throughput_limit
    }
  }

  capabilities {
    name = "EnableMongo"
  }

  dynamic "capabilities" {
    for_each = var.capabilities != null ? var.capabilities : []
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]
    iterator = rule
    content {
      type                = rule.value.type
      interval_in_minutes = rule.value.interval_in_minutes
      retention_in_hours  = rule.value.retention_in_hours
      storage_redundancy  = rule.value.storage_redundancy
    }
  }
  access_key_metadata_writes_enabled = false

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
}


resource "azurerm_cosmosdb_mongo_database" "main" {
  for_each = var.databases

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = each.value.throughput

  dynamic "autoscale_settings" {
    for_each = each.value.max_throughput != null ? [each.value.max_throughput] : []
    content {
      max_throughput = autoscale_settings.value
    }
  }
}

resource "azurerm_cosmosdb_mongo_collection" "main" {
  for_each = { for col in local.collections : col.name => col }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = each.value.database
  shard_key           = each.value.shard_key
  throughput          = each.value.throughput

  dynamic "autoscale_settings" {
    for_each = each.value.max_throughput != null ? [each.value.max_throughput] : []
    content {
      max_throughput = autoscale_settings.value
    }
  }
  index {
    keys   = ["_id"]
    unique = true
  }

  lifecycle {
    ignore_changes = [index]
  }

  depends_on = [azurerm_cosmosdb_mongo_database.main]
}

data "azurerm_monitor_diagnostic_categories" "default" {
  resource_id = azurerm_cosmosdb_account.main.id
}

resource "azurerm_monitor_diagnostic_setting" "cosmosdb" {
  count                          = var.diagnostics != null ? 1 : 0
  name                           = "${lower(var.name)}${random_string.random.result}"
  target_resource_id             = azurerm_cosmosdb_account.main.id
  log_analytics_workspace_id     = local.parsed_diag.log_analytics_id
  eventhub_authorization_rule_id = local.parsed_diag.event_hub_auth_id
  eventhub_name                  = local.parsed_diag.event_hub_auth_id != null ? var.diagnostics.eventhub_name : null
  storage_account_id             = local.parsed_diag.storage_account_id

  # For each available log category, check if it should be enabled and set enabled = true if it should.
  # All other categories are created with enabled = false to prevent TF from showing changes happening with each plan/apply.
  # Ref: https://github.com/terraform-providers/terraform-provider-azurerm/issues/7235
  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.logs
    content {
      category = log.value
      enabled  = contains(local.parsed_diag.log, "all") || contains(local.parsed_diag.log, log.value)

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  # For each available metric category, check if it should be enabled and set enabled = true if it should.
  # All other categories are created with enabled = false to prevent TF from showing changes happening with each plan/apply.
  # Ref: https://github.com/terraform-providers/terraform-provider-azurerm/issues/7235
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.metrics
    content {
      category = metric.value
      enabled  = contains(local.parsed_diag.metric, "all") || contains(local.parsed_diag.metric, metric.value)

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
