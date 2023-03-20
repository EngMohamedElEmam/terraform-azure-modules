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
  type        = string
  description = "The name of api managment instance."
}

variable "sku_name" {
  type        = string
  description = "String consisting of two parts separated by an underscore. The fist part is the name, valid values include: Developer, Basic, Standard and Premium. The second part is the capacity"
  default     = "Basic_1"
}

variable "publisher_name" {
  type        = string
  description = "The name of publisher/company."
}

variable "publisher_email" {
  type        = string
  description = "The email of publisher/company."
}

variable "additional_location" {
  type        = list(map(string))
  description = "List of the name of the Azure Region in which the API Management Service should be expanded to."
  default     = []
}

variable "certificate_configuration" {
  type        = list(map(string))
  description = "List of certificate configurations"
  default     = []
}

variable "enable_http2" {
  type        = bool
  description = "Should HTTP/2 be supported by the API Management Service?"
  default     = false
}

variable "management_hostname_configuration" {
  type        = list(map(string))
  description = "List of management hostname configurations"
  default     = []
}

variable "scm_hostname_configuration" {
  type        = list(map(string))
  description = "List of scm hostname configurations"
  default     = []
}

variable "proxy_hostname_configuration" {
  type        = list(map(string))
  description = "List of proxy hostname configurations"
  default     = []
}

variable "gateway_hostname_configuration" {
  type        = list(map(string))
  description = "List of gateway hostname configurations"
  default     = []
}

variable "data_certname" {
  type        = string
  description = "Name of imported cert from subscription"
}

variable "data_keyvault_id" {
  type        = string
  description = "Name of imported key vault from subscription"
}

variable "portal_hostname_configuration" {
  type        = list(map(string))
  description = "Legacy portal hostname configurations"
  default     = []
}

variable "developer_portal_hostname_configuration" {
  type        = list(map(string))
  description = "Developer portal hostname configurations"
  default     = []
}

variable "notification_sender_email" {
  type        = string
  description = "Email address from which the notification will be sent"
  default     = null
}

variable "policy_configuration" {
  type        = map(string)
  description = "Map of policy configuration"
  default     = {}
}

variable "enable_sign_in" {
  type        = bool
  description = "Should anonymous users be redirected to the sign in page?"
  default     = false
}

variable "enable_sign_up" {
  type        = bool
  description = "Can users sign up on the development portal?"
  default     = false
}

variable "terms_of_service_configuration" {
  type        = list(map(string))
  description = "Map of terms of service configuration"

  default = [{
    consent_required = false
    enabled          = false
    text             = ""
  }]
}

variable "security_configuration" {
  type        = map(string)
  description = "Map of security configuration"
  default     = {}
}

### NETWORKING

variable "virtual_network_type" {
  type        = string
  description = "The type of virtual network you want to use, valid values include: None, External, Internal."
  default     = null
}

variable "virtual_network_configuration" {
  type        = list(string)
  description = "The id(s) of the subnet(s) that will be used for the API Management. Required when virtual_network_type is External or Internal"
  default     = []
}

variable "nsg_name" {
  type        = string
  description = "NSG name of the subnet hosting the APIM to add the rule to allow management if the APIM is private"
  default     = null
}

variable "nsg_rg_name" {
  type        = string
  description = "Name of the RG hosting the NSG if it's different from the one hosting the APIM"
  default     = null
}

variable "create_management_rule" {
  type        = bool
  description = "Whether to create the NSG rule for the management port of the APIM. If true, nsg_name variable must be set"
  default     = false
}

variable "management_nsg_rule_priority" {
  type        = number
  description = "Priority of the NSG rule created for the management port of the APIM"
  default     = 101
}

### IDENTITY

variable "identity_type" {
  description = "Type of Managed Service Identity that should be configured on this API Management Service"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "A list of IDs for User Assigned Managed Identity resources to be assigned. This is required when type is set to UserAssigned or SystemAssigned, UserAssigned."
  type        = list(string)
  default     = []
}

variable "named_values" {
  description = "Map containing the name of the named values as key and value as values"
  type        = list(map(string))
  default     = []
}

/* variable "operations" {
  type = list(object({
    name           = string
    operation_name = string
    method         = string
    url_template   = string
    xml_content    = string
  }))
}
*/
variable "apiAndOperation" {
  type = list(object({
    name           = string
    path           = string
    content_format = string
    content_value  = string
  }))
}

variable "products" {
  description = "List of products to create"
  type        = list(string)
  default     = []
}

variable "create_product_group_and_relationships" {
  description = "Create local APIM groups with name identical to products and create a relationship between groups and products"
  type        = bool
  default     = false
}


###App Insight

variable "app_insight_name" {
  description = "The app insight Name for the apim"
  type        = string
}

variable "instrumentation_key" {
  description = "instrumentation_key of the app insight to be able to store data on app insight connected to the apim"
  type        = string
}

variable "app_insight" {
  description = "The app insight id to connect to the apim"
  type        = string
}

variable "depends" {
  description = "depends_on"
  type        = any
}
