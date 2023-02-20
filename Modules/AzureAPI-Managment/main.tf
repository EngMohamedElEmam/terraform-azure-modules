terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
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

resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_api_management" "apim" {
  name                = "${lower(var.name)}${random_string.random.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email
  sku_name        = var.sku_name

  dynamic "additional_location" {
    for_each = var.additional_location
    content {
      location = lookup(additional_location.value, "location", null)
      dynamic "virtual_network_configuration" {
        for_each = lookup(additional_location.value, "subnet_id", null) == null ? [] : [1]
        content {
          subnet_id = additional_location.value.subnet_id
        }
      }
    }
  }

  dynamic "certificate" {
    for_each = var.certificate_configuration
    content {
      encoded_certificate  = lookup(certificate.value, "encoded_certificate")
      certificate_password = lookup(certificate.value, "certificate_password")
      store_name           = lookup(certificate.value, "store_name")
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = replace(var.identity_type, "UserAssigned", "") == var.identity_type ? null : var.identity_ids
  }

  dynamic "hostname_configuration" {
    for_each = length(concat(
      var.management_hostname_configuration,
      var.portal_hostname_configuration,
      var.developer_portal_hostname_configuration,
      var.proxy_hostname_configuration,
    )) == 0 ? [] : ["fake"]

    content {
      dynamic "management" {
        for_each = var.management_hostname_configuration
        content {
          host_name                    = lookup(management.value, "host_name")
          key_vault_id                 = lookup(management.value, "key_vault_id", null)
          certificate                  = lookup(management.value, "certificate", null)
          certificate_password         = lookup(management.value, "certificate_password", null)
          negotiate_client_certificate = lookup(management.value, "negotiate_client_certificate", false)
        }
      }

      dynamic "portal" {
        for_each = var.portal_hostname_configuration
        content {
          host_name                    = lookup(portal.value, "host_name")
          key_vault_id                 = lookup(portal.value, "key_vault_id", null)
          certificate                  = lookup(portal.value, "certificate", null)
          certificate_password         = lookup(portal.value, "certificate_password", null)
          negotiate_client_certificate = lookup(portal.value, "negotiate_client_certificate", false)
        }
      }

      dynamic "developer_portal" {
        for_each = var.developer_portal_hostname_configuration
        content {
          host_name                    = lookup(developer_portal.value, "host_name")
          key_vault_id                 = lookup(developer_portal.value, "key_vault_id", null)
          certificate                  = lookup(developer_portal.value, "certificate", null)
          certificate_password         = lookup(developer_portal.value, "certificate_password", null)
          negotiate_client_certificate = lookup(developer_portal.value, "negotiate_client_certificate", false)
        }
      }

      dynamic "proxy" {
        for_each = var.proxy_hostname_configuration
        content {
          host_name                    = lookup(proxy.value, "host_name")
          default_ssl_binding          = lookup(proxy.value, "default_ssl_binding", false)
          key_vault_id                 = lookup(proxy.value, "key_vault_id", null)
          certificate                  = lookup(proxy.value, "certificate", null)
          certificate_password         = lookup(proxy.value, "certificate_password", null)
          negotiate_client_certificate = lookup(proxy.value, "negotiate_client_certificate", false)
        }
      }

      dynamic "scm" {
        for_each = var.scm_hostname_configuration
        content {
          host_name                    = lookup(scm.value, "host_name")
          key_vault_id                 = lookup(scm.value, "key_vault_id", null)
          certificate                  = lookup(scm.value, "certificate", null)
          certificate_password         = lookup(scm.value, "certificate_password", null)
          negotiate_client_certificate = lookup(scm.value, "negotiate_client_certificate", false)
        }
      }

    }
  }

  notification_sender_email = var.notification_sender_email

  dynamic "policy" {
    for_each = var.policy_configuration
    content {
      xml_content = lookup(policy.value, "xml_content", null)
      xml_link    = lookup(policy.value, "xml_link", null)
    }
  }

  protocols {
    enable_http2 = var.enable_http2
  }

  dynamic "security" {
    for_each = var.security_configuration
    content {
      enable_backend_ssl30                                = lookup(security.value, "enable_backend_ssl30", false)
      enable_backend_tls10                                = lookup(security.value, "enable_backend_tls10", false)
      enable_backend_tls11                                = lookup(security.value, "enable_backend_tls11", false)
      enable_frontend_ssl30                               = lookup(security.value, "enable_frontend_ssl30", false)
      enable_frontend_tls10                               = lookup(security.value, "enable_frontend_tls10", false)
      enable_frontend_tls11                               = lookup(security.value, "enable_frontend_tls11", false)
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = try(security.value.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled, null)
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = try(security.value.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled, null)
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = try(security.value.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled, null)
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = try(security.value.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled, null)
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = try(security.value.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled, null)
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = try(security.value.tls_rsa_with_aes128_cbc_sha_ciphers_enabled, null)
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = try(security.value.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled, null)
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = try(security.value.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled, null)
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = try(security.value.tls_rsa_with_aes256_cbc_sha_ciphers_enabled, null)
      triple_des_ciphers_enabled                          = try(security.value.triple_des_ciphers_enabled, null)
    }
  }

  sign_in {
    enabled = var.enable_sign_in
  }

  sign_up {
    enabled = var.enable_sign_up
    dynamic "terms_of_service" {
      for_each = var.terms_of_service_configuration
      content {
        consent_required = lookup(terms_of_service.value, "consent_required")
        enabled          = lookup(terms_of_service.value, "enabled")
        text             = lookup(terms_of_service.value, "text")
      }
    }
  }

  virtual_network_type = var.virtual_network_type

  dynamic "virtual_network_configuration" {
    for_each = toset(var.virtual_network_configuration)
    content {
      subnet_id = virtual_network_configuration.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [azurerm_network_security_rule.management_apim]
  tags = local.common_tags
}

data "azurerm_key_vault_secret" "certificate_secret" {
  name         = var.data_certname
  key_vault_id = var.data_keyvault_id
}

resource "azurerm_api_management_custom_domain" "domain" {
  api_management_id = azurerm_api_management.apim.id

  dynamic "gateway" {
    for_each = var.gateway_hostname_configuration
    content {
      host_name                    = lookup(gateway.value, "host_name")
      key_vault_id                 = trimsuffix(data.azurerm_key_vault_secret.certificate_secret.id, "${data.azurerm_key_vault_secret.certificate_secret.version}")
      certificate                  = lookup(gateway.value, "certificate", null)
      certificate_password         = lookup(gateway.value, "certificate_password", null)
      negotiate_client_certificate = lookup(gateway.value, "negotiate_client_certificate", false)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#Network
resource "azurerm_network_security_rule" "management_apim" {
  count                       = var.create_management_rule ? 1 : 0
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow_apim_management"
  network_security_group_name = var.nsg_name
  priority                    = var.management_nsg_rule_priority
  protocol                    = "Tcp"
  resource_group_name         = var.nsg_rg_name == null ? var.resource_group_name : var.nsg_rg_name

  source_port_range          = "*"
  destination_port_range     = "3443"
  source_address_prefix      = "ApiManagement"
  destination_address_prefix = "VirtualNetwork"
}

#Products-Groups
resource "azurerm_api_management_group" "group" {
  for_each            = var.create_product_group_and_relationships ? toset(var.products) : []
  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  display_name        = each.key
}

resource "azurerm_api_management_product" "product" {
  for_each              = toset(var.products)
  product_id            = each.key
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.apim.name
  display_name          = each.key
  subscription_required = true
  approval_required     = true
  published             = true
  subscriptions_limit   = 1
}

resource "azurerm_api_management_product_group" "product_group" {
  for_each            = var.create_product_group_and_relationships ? toset(var.products) : []
  product_id          = each.key
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  group_name          = each.key
}

#Named Values
resource "azurerm_api_management_named_value" "named_values" {
  for_each            = { for named_value in var.named_values : named_value["name"] => named_value }
  api_management_name = azurerm_api_management.apim.name
  display_name        = lookup(each.value, "display_name", lookup(each.value, "name"))
  name                = lookup(each.value, "name")
  resource_group_name = var.resource_group_name
  value               = lookup(each.value, "value")
  secret              = lookup(each.value, "secret", false)
}

#Connect to AppInsight
resource "azurerm_api_management_logger" "logger" {
  name                = var.app_insight_name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  resource_id         = var.app_insight

  application_insights {
    instrumentation_key = var.instrumentation_key
  }
}

# Import heartbeat API 
resource "azurerm_api_management_api" "apiHealthProbe" {
  name                = "health-probe"
  resource_group_name = azurerm_api_management.apim.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Health probe"
  path                = "health-probe"
  protocols           = ["https"]

  subscription_key_parameter_names {
    header = "AppKey"
    query  = "AppKey"
  }

  import {
    content_format = "swagger-json"
    content_value  = <<JSON
      {
          "swagger": "2.0",
          "info": {
              "version": "1.0.0",
              "title": "Health probe"
          },
          "host": "not-used-direct-response",
          "basePath": "/",
          "schemes": [
              "https"
          ],
          "consumes": [
              "application/json"
          ],
          "produces": [
              "application/json"
          ],
          "paths": {
              "/": {
                  "get": {
                      "operationId": "get-ping",
                      "responses": {}
                  }
              }
          }
      }
    JSON
  }
}

# set api level policy on the API to return HTTP 200.
resource "azurerm_api_management_api_policy" "apiHealthProbePolicy" {
  api_name            = azurerm_api_management_api.apiHealthProbe.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  api_management_name = azurerm_api_management.apim.name

  xml_content = <<XML
    <policies>
      <inbound>
        <return-response>
            <set-status code="200" />
        </return-response>
        <base />
      </inbound>
    </policies>
  XML
}

# Import API 
resource "azurerm_api_management_api" "apis" {
  for_each              = { for v in var.apiAndOperation : v.name => v }
  name                  = each.value.name
  resource_group_name   = azurerm_api_management.apim.resource_group_name
  api_management_name   = azurerm_api_management.apim.name
  revision              = "1"
  display_name          = each.value.name
  path                  = each.value.path
  protocols             = ["https"]
  subscription_required = true

  import {
    content_format = each.value.content_format
    content_value  = each.value.content_value
  }

  subscription_key_parameter_names {
    header = "Ocp-Apim-Subscription-Key"
    query  = "subscription-key"
  }
  timeouts {}
}


/* 
# Import API 
resource "azurerm_api_management_api" "apiExample" {
  name                = "Example API"
  resource_group_name = azurerm_api_management.apim.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Example API"
  path                = "Example API"
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}
 */

/* #Enable Monitoring for Example API
resource "azurerm_api_management_api_diagnostic" "apidiag" {
  for_each                 = toset(var.apiAndOperation)
  identifier               = "applicationinsights"
  resource_group_name      = azurerm_api_management.apim.resource_group_name
  api_management_name      = azurerm_api_management.apim.name
  api_name                 = var.api_name
  api_management_logger_id = azurerm_api_management_logger.logger.id

  sampling_percentage       = 5.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }
}
 */
