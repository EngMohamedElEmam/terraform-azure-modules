variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "The location for the deployment"
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

variable "container_name" {
  type        = string
  description = "The storage container name"
}

variable "storage_account_name" {
  type        = string
  description = "The storage account name"
}

variable "storage_account_id" {
  type        = string
  description = "The storage account id"
}

variable "blob_name" {
  type        = string
  description = "The blob storage name"
}

variable "container_access_type" {
  type        = string
  description = "The container_access_type"
}

variable "backup_vault_name" {
  type        = string
  description = "The recovery vault data protection backup vault name"
}

variable "vault_datastore_type" {
  type        = string
  description = "Specifies the type of the data store. Possible values are ArchiveStore, SnapshotStore and VaultStore."
}

variable "vault_redundancy" {
  type        = string
  description = "Specifies the backup storage redundancy. Possible values are GeoRedundant and LocallyRedundant"
}

variable "backup_policy_blob_name" {
  type        = string
  description = "The recovery vault data protection backup policy name"
}

variable "backup_instance_blob_storage_name" {
  type        = string
  description = "The recovery vault data protection backup instance blob storage name"
}

variable "backup_retention_duration" {
  type        = string
  description = "Duration of deletion after given timespan. It should follow ISO 8601 duration format. Changing this forces a new Backup Policy Blob Storage to be created."
}

