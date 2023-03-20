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
  logs_destinations_ids = var.logs_destinations_ids == null ? [] : var.logs_destinations_ids
  enabled               = length(local.logs_destinations_ids) > 0

  log_categories = (
    var.log_categories != null ?
    var.log_categories :
    try(data.azurerm_monitor_diagnostic_categories.main[0].logs, [])
  )
  metric_categories = (
    var.metric_categories != null ?
    var.metric_categories :
    try(data.azurerm_monitor_diagnostic_categories.main[0].metrics, [])
  )

  logs = {
    for category in try(data.azurerm_monitor_diagnostic_categories.main[0].logs, []) : category => {
      enabled        = contains(local.log_categories, category)
      retention_days = var.retention_days
    }
  }

  metrics = {
    for metric in try(data.azurerm_monitor_diagnostic_categories.main[0].metrics, []) : metric => {
      enabled        = contains(local.metric_categories, metric)
      retention_days = var.retention_days
    }
  }

  storage_id       = coalescelist([for r in local.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.storage")], [null])[0]
  log_analytics_id = coalescelist([for r in local.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.operationalinsights")], [null])[0]
  eventhub_id      = coalescelist([for r in local.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.eventhub")], [null])[0]

  log_analytics_destination_type = local.log_analytics_id != null ? var.log_analytics_destination_type : null
}


data "azurerm_monitor_diagnostic_categories" "main" {
  count = local.enabled ? 1 : 0

  resource_id = var.resource_id
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = local.enabled ? 1 : 0

  name               = var.diag_name
  target_resource_id = var.resource_id

  storage_account_id             = local.storage_id
  log_analytics_workspace_id     = local.log_analytics_id
  log_analytics_destination_type = local.log_analytics_destination_type
  eventhub_authorization_rule_id = local.eventhub_id

  dynamic "log" {
    for_each = local.logs

    content {
      category = log.key
      enabled  = log.value.enabled

      retention_policy {
        enabled = log.value.enabled && log.value.retention_days != null ? true : false
        days    = log.value.enabled ? log.value.retention_days : 0
      }
    }
  }

  dynamic "metric" {
    for_each = local.metrics

    content {
      category = metric.key
      enabled  = metric.value.enabled

      retention_policy {
        enabled = metric.value.enabled && metric.value.retention_days != null ? true : false
        days    = metric.value.enabled ? metric.value.retention_days : 0
      }
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
