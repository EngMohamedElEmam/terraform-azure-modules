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

variable "key_vault_id" {
  description = "Id of the Key Vault"
  type        = string
}

variable "role_assignment" {
  description = "role assignment"
}

variable "key_properties" {
  description = "Definesprivate key properties"
  default     = null

  type = object({
    exportable = bool,
    key_size   = number,
    key_type   = string,
    reuse_key  = bool,
  })
}

variable "action_type" {
  description = "The Type of action to be performed when the lifetime trigger is triggerec. Possible values include AutoRenew and EmailContacts"
  type        = string
  default     = "AutoRenew"
}

variable "days_before_expiry" {
  description = "The number of days before the Certificate expires that the action associated with this Trigger should run. Conflicts with lifetime_percentage."
  type        = number
  default     = 30
}

variable "content_type" {
  description = "(Required) The Content-Type of the Certificate, such as application/x-pkcs12 for a PFX or application/x-pem-file for a PEM."
  type        = string
}

variable "extended_key_usage" {
  description = "A list of Extended/Enhanced Key Usages. Changing this forces a new resource to be created. # Server Authentication = 1.3.6.1.5.5.7.3.1 # Client Authentication = 1.3.6.1.5.5.7.3.2"
  type        = list(string)
}

variable "sans" {
  description = "A list of alternative DNS names (FQDNs) identified by the Certificate."
  type        = list(string)
}

variable "emails" {
  description = "A list of email addresses identified by this Certificate. "
  type        = list(string)
}

variable "common_name" {
  description = "(Required) The Certificate's common name. CN"
  type        = string
}

variable "validity" {
  description = "The Certificates Validity Period in Months."
  type        = number
}





