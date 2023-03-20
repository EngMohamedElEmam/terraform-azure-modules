variable "resource_group_name" {
  type        = string
  description = "The resource group for the deployment"
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
variable "name" {
  description = "Name of the CosmosDB Account."
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}

variable "kind" {
  description = "Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created."
}

variable "enable_free_tier" {
  type        = bool
  default     = false
  description = "(Optional)  Enable Free Tier pricing option for this Cosmos DB account. Defaults to false"
}

variable "enable_automatic_failover" {
  type        = bool
  default     = false
  description = "(Optional) Enable automatic fail over for this Cosmos DB account."
}

variable "zone_redundant" {
  type        = bool
  default     = false
  description = "(Optional) Should zone redundancy be enabled for this region? Defaults to false."
}

variable "failover_location" {
  type        = string
  default     = null
  description = "Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location."
}

variable "capacity" {
  description = "(Required) The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit."
  default     = null

  type = object({
    total_throughput_limit = optional(number),
  })
}

variable "backup" {
  description = "The type of the backup. Possible values are Continuous and Periodic. Defaults to Periodic. Migration of Periodic to Continuous is one-way, changing Continuous to Periodic"
  default     = null

  type = object({
    type                = optional(string),
    interval_in_minutes = optional(number), # The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440.
    retention_in_hours  = optional(number), # The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720.
    storage_redundancy  = optional(string), #The storage redundancy which is used to indicate type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone.
  })
}

variable "access_key_metadata_writes_enabled" {
  type        = bool
  default     = false
  description = "Is write operations on metadata resources (databases, containers, throughput) via account keys enabled? "
}

variable "mongo_server_version" {
  type        = number
  description = "The Server Version of a MongoDB account. Possible values are 4.0, 3.6, and 3.2."
}

variable "databases" {
  description = "List of databases"
  type = map(object({
    throughput     = number
    max_throughput = number
    collections = list(object({
      name           = string
      shard_key      = string
      throughput     = number
      max_throughput = number
    }))
  }))
  default = {}
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type = object({
    destination   = string
    eventhub_name = string
    logs          = list(string)
    metrics       = list(string)
  })
  default = null
}

variable "public_network_access" {
  type        = bool
  default     = true
  description = "(Optional) Whether or not public network access is allowed for this CosmosDB account."
}

variable "bypass_for_azure_services" {
  type        = bool
  default     = false
  description = "(Optional)  If azure services can bypass ACLs. Defaults to false."
}

variable "ip_range_filter" {
  description = "CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account. To enable the Accept connections from within public Azure datacenters behavior, you should add 0.0.0.0 and To enable the (Allow access from the Azure portal) behavior, you should add the IP addresses provided by Microsoft (51.4.229.218, 139.217.8.252, 52.244.48.71, 104.42.195.92 , 40.76.54.131 , 52.176.6.30 , 52.169.50.45 , 52.187.184.26)"
  type        = list(string)
  default     = []
}

variable "bypass_resources_ids" {
  description = "The list of resource Ids for Network Acl Bypass for this Cosmos DB account."
  type        = list(any)
  default     = []
}

variable "virtual_network_enabled" {
  description = "Enables virtual network filtering for this Cosmos DB account."
  type        = bool
  default     = false
}

variable "virtual_network_rule" {
  description = "Configures the virtual network subnets allowed to access this Cosmos DB :  (Required) The ID of the virtual network subnet."
  default     = null

  type = object({
    vnet_subnet_ids = optional(any),
  })
}

variable "capabilities" {
  description = "Configures the capabilities to enable for this Cosmos DB account. Check README.md for valid values."
  type        = list(string)
  default     = null
}
