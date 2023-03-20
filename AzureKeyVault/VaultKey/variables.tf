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

variable "key_name" {
  description = "Specifies the name of the Key Vault Key. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "key_type" {
  description = "Specifies the Key Type to use for this Key Vault Key. Possible values are EC (Elliptic Curve), EC-HSM, Oct (Octet), RSA and RSA-HSM. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "key_size" {
  description = "Specifies the Size of the RSA key to create in bytes. For example, 1024 or 2048. Note: This field is required if key_type is RSA or RSA-HSM. Changing this forces a new resource to be created."
  type        = number
}

variable "key_vault_id" {
  description = "Id of the Key Vault"
  type        = string
}

variable "role_assignment" {
  description = "role assignment"
}

