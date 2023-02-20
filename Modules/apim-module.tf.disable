##########################
# API Management Modules #
##########################

# Create resource groups
module "apim-rg" {
  source   = "./ResourceGroup"
  rg_name  = "pharma-apim"
  location = "East US"
}

#Create Key Vault
module "Pharma-keyvault" {
  source                          = "./AzureKeyVault"
  resource_group_name             = module.apim-rg.rg_name_out
  location                        = "East US"
  key_vault_name                  = "pharmakv"
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  soft_delete_enabled             = true
  soft_delete_retention_days      = 7
  role_definition_name            = "Key Vault Administrator"

  network_acls = {
    bypass         = "AzureServices" #"None"
    default_action = "Allow"         #"Deny"
    #ip_rules       = ["40.10.2.4", "40.10.2.5", "102.190.233.109"]
  }

  access_policy = {
    object_id               = data.azurerm_client_config.current.object_id
    certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "DeleteIssuers", "GetIssuers", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers"]
    key_permissions         = ["Create", "Get", "Import", "List", "Update", "Backup", "Decrypt", "Delete", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Verify", "WrapKey"]
    secret_permissions      = ["Get", "List", "Set", "Backup", "Delete", "Purge", "Recover", "Restore"]
  }
}

#Import Certificate Vault Certificate
module "Pharma-keyvault-importcert" {
  source                = "./AzureKeyVault/Vaultcertificate-import"
  key_vault_id          = module.Pharma-keyvault.key_vault_id
  certificate_to_import = filebase64("./AzureKeyVault/Vaultcertificate-import/emam-fun.pfx")
  cert_name             = "pharmacert"
  cert_password         = 123
  role_assignment       = module.Pharma-keyvault.role_assignment_id
}

#RBAC to keyvault
module "RoleAssignment-kv" {
  for_each = local.rolekv
  source   = "./Identity/RoleAssignmentAD"

  role_definition_name = each.key
  scope_id             = module.Pharma-keyvault.key_vault_id
  principal_ids        = each.value
  depends              = [module.Pharma-keyvault]
}

# Create APIM
module "apim" {
  source              = "./AzureAPI-Managment"
  resource_group_name = module.apim-rg.rg_name_out
  location            = "East US"
  name                = "APIM"
  sku_name            = "Developer_1" #or "Premium_1"
  publisher_name      = "DevOps Team"
  publisher_email     = "devops@pharma.com"
  data_certname       = module.Pharma-keyvault-importcert.cert_name
  data_keyvault_id    = module.Pharma-keyvault.key_vault_id

  gateway_hostname_configuration = [
    {
      host_name = "devops.emam.fun"
    },
  ]

  apiAndOperation = [
    {
      name           = "demo-example-api"
      display_name   = "Demo Example API"
      path           = "example"
      content_format = "swagger-link-json"
      content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
    },
  ]


  /*   operations = [
    {
      name           = "exampleApi"
      operation_name = "getExample"
      method         = "GET"
      url_template   = "/example"
      xml_content    = <<XML
              <policies>
                  <inbound>
            <base />
                  </inbound>
                  <backend>
                      <base />
                  </backend>
                  <outbound>
                      <base />
                  </outbound>
                  <on-error>
                      <base />
                  </on-error>
              </policies>
          XML
    },
  ] */

  named_values = [
    {
      name   = "my_value"
      value  = "my secret value"
      secret = true
    },
    {
      display_name = "My_second_value_explained"
      name         = "my_second_value"
      value        = "my not secret value"
    }
  ]

 /*  additional_location = [
    {
      location = "eastus2"
    },
  ]
  */

  instrumentation_key = module.PharmaAPIM-Insight.instrumentation_key
  app_insight         = module.PharmaAPIM-Insight.id
  app_insight_name    = module.PharmaAPIM-Insight.app_insight_name

  depends = [module.Pharma-keyvault, module.Pharma-keyvault-importcert]
}


# Create Log analytics workspace for Diagnostic Settings APIM
module "PharmaAPIM-LogWorkSpace" {
  source                                    = "./AzureLogging/logs"
  resource_group_name                       = module.apim-rg.rg_name_out
  location                                  = "East US"
  log_analytics                             = "pharmaapim-workspace"
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_retention_in_days = "90"
}

# Create storage account to archive or keep APIM data
module "PharmaAPIM-SA" {
  source                   = "./StorageAccount"
  resource_group_name      = module.apim-rg.rg_name_out
  location                 = "East US"
  account_tier             = "Standard"  #or "Premium"
  account_kind             = "StorageV2" #or "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"
  access_tier              = "Hot"       #or "Cool"
  account_replication_type = "LRS"       #or "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"
  base_name                = "pharmaapim"
  delete_retention_policy  = 365
}

# Create Diagnostic Settings for APIM
module "PharmaSA-DiagnosticSettings" {
  source              = "./AzureLogging/DiagnosticSettings"
  resource_group_name = module.apim-rg.rg_name_out
  location            = "East US"
  diag_name           = "apimdiag"
  resource_id         = module.apim.api_management_id
  logs_destinations_ids = [
    module.PharmaAPIM-SA.storage_account_id,
    module.PharmaAPIM-LogWorkSpace.workspace_id
  ]
}

#Create Application Insght for APIM
module "PharmaAPIM-Insight" {
  source               = "./AzureMonitor/AppInsights"
  resource_group_name  = module.apim-rg.rg_name_out
  location             = "East US"
  app_insight_name     = "apim-appinsight"
  application_type     = "web"
  daily_data_cap_in_gb = 50
}

#RBAC for APIM Identity to access keyvault
module "RoleAssignment-apim" {
  source = "./Identity/RoleAssignment"

  role_definition_name = "Key Vault Administrator"
  scope_id             = module.Pharma-keyvault.key_vault_id
  principal_ids        = module.apim.principal_id
  depends              = [module.Pharma-keyvault.key_vault_id]
}



#outputs
output "platform-rgName" {
  value = module.apim-rg.rg_name_out
}

output "platform-rgLocation" {
  value = module.apim-rg.rg_location_out
}

output "key_vault_id" {
  description = "Id of the Key Vault"
  value       = module.Pharma-keyvault.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.Pharma-keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "Uri of the Key Vault"
  value       = module.Pharma-keyvault.key_vault_uri
}

output "imported_cert_name" {
  description = "Name of the Certificate "
  value       = module.Pharma-keyvault-importcert.cert_name
}

output "imported_cert_id" {
  description = "The Key Vault Certificate ID."
  value       = module.Pharma-keyvault-importcert.cert_id
}

output "imported_version_id" {
  description = "The current version of the Key Vault Certificate."
  value       = module.Pharma-keyvault-importcert.version_id
}

output "imported_certificate_data" {
  description = " The raw Key Vault Certificate data represented as a hexadecimal string."
  value       = module.Pharma-keyvault-importcert.certificate_data
}

output "api_management_id" {
  description = " The ID of the API Management Service.."
  value       = module.apim.api_management_id
}

output "api_management_name" {
  description = "The name of the API Management Service"
  value       = module.apim.api_management_name
}

output "api_management_additional_location" {
  description = "Map listing gateway_regional_url and public_ip_addresses associated"
  value       = module.apim.api_management_additional_location
}

output "api_management_gateway_url" {
  description = "The URL of the Gateway for the API Management Service"
  value       = module.apim.api_management_gateway_url
}

output "api_management_gateway_regional_url" {
  description = "The Region URL for the Gateway of the API Management Service"
  value       = module.apim.api_management_gateway_regional_url
}

output "api_management_management_api_url" {
  description = "The URL for the Management API associated with this API Management service"
  value       = module.apim.api_management_management_api_url
}

output "api_management_portal_url" {
  description = "The URL for the Publisher Portal associated with this API Management service"
  value       = module.apim.api_management_portal_url
}

output "api_management_public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service"
  value       = module.apim.api_management_public_ip_addresses
}

output "api_management_private_ip_addresses" {
  description = "The Private IP addresses of the API Management Service"
  value       = module.apim.api_management_private_ip_addresses
}

output "api_management_scm_url" {
  description = "The URL for the SCM Endpoint associated with this API Management service"
  value       = module.apim.api_management_scm_url
}

output "api_management_identity" {
  description = "The identity of the API Management"
  value       = module.apim.api_management_identity
}

output "principal_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = module.apim.api_management_identity.0.principal_id
}
