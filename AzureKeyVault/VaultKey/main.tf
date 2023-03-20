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

resource "azurerm_key_vault_key" "generated" {
  name         = "${lower(var.key_name)}${random_string.random.result}"
  key_vault_id = var.key_vault_id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [var.role_assignment]
  tags = local.common_tags
}


# key_permissions = [
#       "create",
#       "get",
#       "purge",
#       "recover"
#     ]

#     secret_permissions = [
#       "set",
#     ]
