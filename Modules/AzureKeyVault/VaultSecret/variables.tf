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

variable "secret_name" {
  description = "The keyvault name"
  type        = string
  default     = ""
}

variable "secret_value" {
  description = "The Secret Value"
  type        = string
  default     = ""
}

variable "key_vault_id" {
  description = "Id of the Key Vault"
  type        = string
}

variable "role_assignment" {
  description = "role assignment"
}

