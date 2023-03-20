terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
  experiments = [module_variable_optional_attrs]
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

#Create Event hub Namespace
resource "azurerm_eventhub_namespace" "namespace" {
  name                     = "${lower(var.eventhub_namespace_name)}${random_string.random.result}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.namespace_sku
  capacity                 = var.namespace_capacity
  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.namespace_maximum_throughput_units
  zone_redundant           = var.zone_redundant

  dynamic "network_rulesets" {
    for_each = var.network_rulesets == null ? [] : [var.network_rulesets]
    iterator = rule

    content {
      default_action                 = rule.value.default_action
      ip_rule                        = rule.value.ip_rule
      virtual_network_rule           = rule.value.virtual_network_rule
      trusted_service_access_enabled = rule.value.trusted_service_access_enabled
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Define eventhub namespace authorization rules
resource "azurerm_eventhub_namespace_authorization_rule" "events" {
  name                = "manage"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

# Define the eventhub
resource "azurerm_eventhub" "eventhub" {
  name                = "${lower(var.eventhub_name)}${random_string.random.result}"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention
  status              = var.eventhub_status

  capture_description {
    enabled  = var.capture
    encoding = var.encoding

    destination {
      name                = "EventHubArchive.AzureBlockBlob" #The Name of the Destination where the capture should take place. At this time the only supported value is EventHubArchive.AzureBlockBlob."
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}-{Month}-{Day}T{Hour}:{Minute}:{Second}"
      blob_container_name = var.event_blob_container_name
      storage_account_id  = var.event_storage_account_id
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
  depends_on = [azurerm_eventhub_namespace.namespace]
}

# Define eventhub consumers
resource "azurerm_eventhub_consumer_group" "group_rcvr_topic" {
  name                = "kafka-receiver-topic"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  eventhub_name       = azurerm_eventhub.eventhub.name
  resource_group_name = var.resource_group_name

  lifecycle {
    create_before_destroy = true
  }
}

#resource "azurerm_eventhub_consumer_group" "notifications_notifier_appinsights" {
#  name                = "appinsights"
#  namespace_name      = azurerm_eventhub_namespace.namespace.name
#  eventhub_name       = azurerm_eventhub.eventhub.name
#  resource_group_name = var.resource_group_name
#}

#resource "azurerm_eventhub_consumer_group" "notifications_notifier_email" {
#  name                = "email"
#  namespace_name      = azurerm_eventhub_namespace.namespace.name
#  eventhub_name       = azurerm_eventhub.eventhub.name
#  resource_group_name = var.resource_group_name
#}

# Define eventhub authorization rules
resource "azurerm_eventhub_authorization_rule" "kafka_rcvr_manage" {
  name                = "manage"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  eventhub_name       = azurerm_eventhub.eventhub.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true

  lifecycle {
    create_before_destroy = true
  }
}

#resource "azurerm_eventhub_authorization_rule" "notifications_notifier_send" {
#  name                = "send"
#  namespace_name      = azurerm_eventhub_namespace.namespace.name
#  eventhub_name       = azurerm_eventhub.eventhub.name
#  resource_group_name = var.resource_group_name
#  listen              = true
#  send                = true
#  manage              = true
#}

#resource "azurerm_eventhub_authorization_rule" "notifications_notifier_listen" {
#  name                = "listen"
#  namespace_name      = azurerm_eventhub_namespace.namespace.name
#  eventhub_name       = azurerm_eventhub.eventhub.name
#  resource_group_name = var.resource_group_name
#  listen              = true
#  send                = false
#  manage              = false
#}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  name               = "${lower(var.eventhub_diagnostics)}${random_string.random.result}"
  target_resource_id = azurerm_eventhub_namespace.namespace.id
  #storage_account_id           = var.logs_storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  eventhub_name = azurerm_eventhub.eventhub.name

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}