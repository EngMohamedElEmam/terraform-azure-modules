terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
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
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "role" {
  scope                = var.scope_id
  role_definition_name = var.role_definition_name
  principal_id         = var.principal_ids
  depends_on           = [var.depends]
  lifecycle {
    create_before_destroy = true
  }
}
