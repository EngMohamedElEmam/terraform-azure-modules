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

resource "azurerm_key_vault_certificate" "generate" {
  name         = var.cert_name
  key_vault_id = var.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    dynamic "key_properties" {
      for_each = var.key_properties == null ? [] : [var.key_properties]
      iterator = rule

      content {
        exportable = rule.value.exportable
        key_size   = rule.value.key_size
        key_type   = rule.value.key_type
        reuse_key  = rule.value.reuse_key
      }
    }

    lifetime_action {
      action {
        action_type = var.action_type
      }

      trigger {
        days_before_expiry = var.days_before_expiry
      }
    }

    secret_properties {
      content_type = var.content_type
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = var.extended_key_usage

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = var.sans
        emails    = var.emails
      }

      subject            = var.common_name
      validity_in_months = var.validity
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [var.role_assignment]
}

