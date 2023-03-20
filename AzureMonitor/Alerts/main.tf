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

// We need to define the action group
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "${lower(var.email_alert)}${random_string.random.result}"
  resource_group_name = var.resource_group_name
  short_name          = var.short_name

  email_receiver {
    name                    = "sendtoAdmin"
    email_address           = var.email_address
    use_common_alert_schema = true
  }

}

// Here we are defining the metric
resource "azurerm_monitor_metric_alert" "Network_Threshold_alert" {
  name                = "Network-Threshold-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.app_vm.id]
  description         = "The alert will be sent if the Network Out bytes exceeds 70 bytes"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }

  depends_on = [
    azurerm_windows_virtual_machine.app_vm,
    azurerm_monitor_metric_alert.email_alert
  ]
}

