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

variable "eventhub_namespace_name" {
  type        = string
  description = "Specifies the name of the EventHub Namespace"
}

variable "namespace_sku" {
  type        = string
  description = "Specifies the EventHub Namespace SKU"
}

variable "namespace_capacity" {
  type        = number
  description = "Specifies the EventHub Namespace capacity"
}

variable "auto_inflate_enabled" {
  type        = bool
  default     = true
  description = "Specifies the EventHub auto inflate, Auto-Inflate enables you to scale-up your throughput units automatically to meet your usage needs."
}

variable "namespace_maximum_throughput_units" {
  type        = number
  description = "Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20."
}

variable "zone_redundant" {
  type        = bool
  default     = false
  description = "Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones). Changing this forces a new resource to be created. Defaults to false."
}

variable "network_rulesets" {
  description = "Defines the Access policy"
  default     = null

  type = object({
    default_action                 = optional(string),
    ip_rule                        = optional(list(any)),
    virtual_network_rule           = optional(list(any)),
    trusted_service_access_enabled = optional(bool),
  })
}

variable "eventhub_name" {
  type        = string
  description = "Specifies the name of the EventHub"
}

variable "partition_count" {
  type        = number
  description = "Specifies the current number of shards on the Event Hub."
}

variable "message_retention" {
  type        = number
  description = "Specifies the number of days to retain the events for this Event Hub."
}

variable "eventhub_status" {
  type        = string
  default     = "Active"
  description = "Specifies the status of the Event Hub resource. Possible values are Active, Disabled and SendDisabled."
}

variable "capture" {
  type        = bool
  default     = true
  description = "Specifies if the Capture Description is Enabled."
}

variable "encoding" {
  type        = string
  default     = "Avro"
  description = "Specifies the Encoding used for the Capture Description. Possible values are Avro and AvroDeflate."
}

variable "event_blob_container_name" {
  type        = string
  description = " The name of the Container within the Blob Storage Account where messages should be archived."
}

variable "event_storage_account_id" {
  type        = string
  description = " The ID of the Blob Storage Account where messages should be archived."
}

#variable "logs_storage_account_id" {
#type = string
#description = "The ID of the Storage Account where Diagnostic should be archived."
#}

variable "eventhub_diagnostics" {
  type        = string
  description = " The Name of diagnostic settings"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = " The log_analytics_workspace_id for diagnostic settings"
}

