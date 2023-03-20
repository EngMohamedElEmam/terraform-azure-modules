terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
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

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

# Create User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.uai_name

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
}
