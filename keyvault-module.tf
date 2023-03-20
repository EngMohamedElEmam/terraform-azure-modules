/* ####################
#Key Vault Modules #
####################

# Create resource group
module "platform-rg" {
  source   = "./ResourceGroup"
  rg_name  = "pharma-kv"
  location = "West Europe"
}

#Create Key Vault
module "Pharma-keyvault" {
  source                          = "./AzureKeyVault"
  resource_group_name             = module.platform-rg.rg_name_out
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
    object_id               = var.client_id
    certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "DeleteIssuers", "GetIssuers", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers"]
    key_permissions         = ["Create", "Get", "Import", "List", "Update", "Backup", "Decrypt", "Delete", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Verify", "WrapKey"]
    secret_permissions      = ["Get", "List", "Set", "Backup", "Delete", "Purge", "Recover", "Restore"]
  }
}

#Create Key Vault Secret
module "Pharma-keyvault-secret" {
  source          = "./AzureKeyVault/VaultSecret"
  secret_name     = "pharmasecret"
  secret_value    = base64encode("testvalue") # base64encode(file(""./AzureKeyVault/Vaultsecret/emam-fun.pfx""))
  key_vault_id    = module.Pharma-keyvault.key_vault_id
  role_assignment = module.Pharma-keyvault.role_assignment_id
}

#Create Key Vault Key
module "Pharma-keyvault-key" {
  source          = "./AzureKeyVault/VaultKey"
  key_vault_id    = module.Pharma-keyvault.key_vault_id
  key_name        = "pharmakey"
  key_type        = "RSA"
  key_size        = 2048
  role_assignment = module.Pharma-keyvault.role_assignment_id
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

#Create Certificate Vault Certificate
module "Pharma-keyvault-genracert" {
  source             = "./AzureKeyVault/Vaultcertificate-generate"
  key_vault_id       = module.Pharma-keyvault.key_vault_id
  cert_name          = "pharmacertgenra"
  days_before_expiry = 30
  content_type       = "application/x-pkcs12"
  extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
  sans               = ["internal.emam.fun", "*.emam.fun"]
  emails             = ["emam@pharma.org", "mohamed@pharma.org"]
  common_name        = "CN=pharma-cert"
  validity           = 24
  key_properties = {
    exportable = true
    key_size   = 2048
    key_type   = "RSA"
    reuse_key  = true
  }
  role_assignment = module.Pharma-keyvault.role_assignment_id
}


#RBAC to keyvault
module "RoleAssignment-kv" {
  for_each = local.rolekv
  source   = "./Identity/RoleAssignmentAD"

  role_definition_name = each.key
  scope_id             = module.AKS-pharma.aks_id
  principal_ids        = each.value
  depends              = [module.Pharma-keyvault]
}



#outputs
output "platform-rgName" {
  value = module.platform-rg.rg_name_out
}

output "platform-rgLocation" {
  value = module.platform-rg.rg_location_out
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

output "key_name" {
  description = "Name of the Key "
  value       = module.Pharma-keyvault-key.key_name
}
 
output "version" {
  description = "The current version of the Key Vault Key."
  value       = module.Pharma-keyvault-key.version
}

output "versionless_id" {
  description = "The Base ID of the Key Vault Key."
  value       = module.Pharma-keyvault-key.versionless_id
}

output "public_key_pem" {
  description = " The PEM encoded public key of this Key Vault Key."
  value       = module.Pharma-keyvault-key.public_key_pem
}

output "cert_name" {
  description = "Name of the Certificate "
  value       = module.Pharma-keyvault-importcert.cert_name
}

output "cert_id" {
  description = "The Key Vault Certificate ID."
  value       = module.Pharma-keyvault-importcert.cert_id
}

output "version_id" {
  description = "The current version of the Key Vault Certificate."
  value       = module.Pharma-keyvault-importcert.version_id
}

output "certificate_data" {
  description = " The raw Key Vault Certificate data represented as a hexadecimal string."
  value       = module.Pharma-keyvault-importcert.certificate_data
}

output "generate_cert_name" {
  description = "Name of the Certificate "
  value       = module.Pharma-keyvault-genracert.cert_name
}

output "generate_cert_id" {
  description = "The Key Vault Certificate ID."
  value       = module.Pharma-keyvault-genracert.cert_id
}

output "generate_version_id" {
  description = "The current version of the Key Vault Certificate."
  value       = module.Pharma-keyvault-genracert.version_id
}

output "generate_certificate_data" {
  description = " The raw Key Vault Certificate data represented as a hexadecimal string."
  value       = module.Pharma-keyvault-genracert.certificate_data
}
 */
