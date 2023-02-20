variable "location" {
  type        = string
  description = "The location for the deployment"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group for the deployment"
}

variable "environment" {
  type        = string
  default     = "Development"
  description = "Sets the environment for the resources"
}

variable "owner" {
  type        = string
  default     = "Terraform"
  description = "Used in created by tags to identify the owner of the resources."
}

variable "key_vault_name" {
  description = "The keyvault name"
  type        = string
  default     = "standard"
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault. Default is the current one."
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are \"standard\" and \"premium\"."
  type        = string
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. When enabledForDeployment is true, networkAcls.bypass must include AzureServices"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. When enabledForDeployment is true, networkAcls.bypass must include AzureServices"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. When enabledForDeployment is true, networkAcls.bypass must include AzureServices"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Defines the network ACLs rules. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more informations. Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  default     = null

  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
}

variable "access_policy" {
  description = "Defines the Access policy"
  default     = null

  type = object({
    object_id               = optional(string),
    certificate_permissions = optional(list(string)),
    secret_permissions      = optional(list(string)),
    key_permissions         = optional(list(string)),
    storage_permissions     = optional(list(string)),
  })
  #certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "DeleteIssuers", "GetIssuers", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers"] 
  #key_permissions         = ["Create", "Get", "Import", "List", "Update", "Backup", "Decrypt", "Delete", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Verify", "WrapKey"]  
  #secret_permissions      = ["Get", "List", "Set", "Backup", "Delete", "Purge", "Recover", "Restore"] 
  #storage_permissions     = ["Get", "List", "Set", "Backup", "Delete", "Purge", "Recover", "Restore", "ListSAS", "RegenerateKey", "DeleteSAS", "GetSAS", "SetSAS", "Update"]
}

variable "role_definition_name" {
  description = "role_definition_name"
  type        = string
}

variable "soft_delete_enabled" {
  description = "Whether to activate delete protection"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for the specified vault."
  type        = bool
  default     = true
}



