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

variable "role_definition_name" {
  description = "The name of the Role to assign to the chosen Scope."
  type        = string
}
/* 
variable "principal_id" {
  description = "The ID of the principal that is to be assigned the role at the given scope. Can be User, Group or SPN."
  type        = any
} */

variable "scope_id" {
  description = "The scope of role"
  type        = any
}

variable "depends" {
  description = "depends_on"
  type        = any
}

variable "principal_ids" {
  type        = list(string)
  description = "The ID of the principal that is to be assigned the role at the given scope. Can be User, Group or SPN."
}

