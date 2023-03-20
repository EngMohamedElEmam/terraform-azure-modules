terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

resource "random_string" "random" {
  length  = 7
  special = true
  upper   = true
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
}

resource "azurerm_key_vault_secret" "secret" {
  name         = var.secret_name
  value        = "${lower(var.secret_value)}${random_string.random.result}"
  key_vault_id = var.key_vault_id
  depends_on   = [var.role_assignment]

  lifecycle {
    create_before_destroy = true
  }
  tags = local.common_tags
}

#key_permissions = [
#     "create",
#    "get",
#   ]#

#   secret_permissions = [
#     "set",
#     "get",
#     "delete",
#     "purge",
#     "recover"
#   ]
