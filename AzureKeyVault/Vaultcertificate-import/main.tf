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

resource "azurerm_key_vault_certificate" "cert" {
  name         = var.cert_name
  key_vault_id = var.key_vault_id

  certificate {
    contents = var.certificate_to_import
    password = var.cert_password
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [var.role_assignment]
  tags = local.common_tags
}

