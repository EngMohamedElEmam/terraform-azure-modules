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

variable "cert_name" {
  description = "Specifies certifecate name"
  type        = string
  default     = ""
}

variable "certificate_to_import" {
  description = "Specifies certifecate name"
}

variable "cert_password" {
  description = "Specifies certifecate password"
}

variable "key_vault_id" {
  description = "Id of the Key Vault"
  type        = string
}

variable "role_assignment" {
  description = "role assignment"
}

