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

data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

resource "azurerm_key_vault" "self" {
  name                = "${lower(var.key_vault_name)}${random_string.random.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.sku_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  purge_protection_enabled        = var.soft_delete_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    iterator = rule

    content {
      bypass                     = coalesce(rule.value.bypass, "None")
      default_action             = coalesce(rule.value.default_action, "Deny")
      virtual_network_subnet_ids = rule.value.virtual_network_subnet_ids
      ip_rules                   = rule.value.ip_rules
    }
  }

  dynamic "access_policy" {
    for_each = var.access_policy == null ? [] : [var.access_policy]
    iterator = rule

    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = rule.value.object_id
      certificate_permissions = rule.value.certificate_permissions
      key_permissions         = rule.value.key_permissions
      secret_permissions      = rule.value.secret_permissions
      storage_permissions     = rule.value.storage_permissions
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
}

resource "azurerm_role_assignment" "role-keyvault-admin" {
  role_definition_name = var.role_definition_name
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.self.id
  depends_on           = [azurerm_key_vault.self]

  lifecycle {
    create_before_destroy = true
  }
}