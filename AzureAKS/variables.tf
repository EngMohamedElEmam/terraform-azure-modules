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

variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group."
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy"
  type        = string
  default     = ""
}

variable "api_server_authorized_ip_ranges" {
  description = "Ip ranges allowed to interract with Kubernetes API. Default no restrictions"
  type        = list(string)
  default     = []
}

variable "node_resource_group" {
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
  type        = string
  default     = null
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies"
  type        = bool
  default     = false
}

variable "private_cluster_enabled" {
  description = "Configure AKS as a Private Cluster : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled"
  type        = bool
  default     = false
}

variable "vnet_id" {
  description = "Vnet id that Aks MSI should be network contributor in a private cluster"
  type        = string
  default     = null
}

variable "appgw_identity_enabled" {
  description = "Configure a managed service identity for Application gateway used with AGIC (useful to configure ssl cert into appgw from keyvault)"
  type        = bool
  default     = false
}

variable "private_dns_zone_type" {
  type        = string
  default     = null #"System"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private_dns_zone_id> variable
If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"
and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone
- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is custom"
}

variable "aks_user_assigned_identity_resource_group_name" {
  description = "Resource Group where to deploy the aks user assigned identity resource. Used when private cluster is enabled and when Azure private dns zone is not managed by aks"
  type        = string
  default     = null
}

variable "aks_user_assigned_identity_custom_name" {
  description = "Custom name for the aks user assigned identity resource"
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "aks sku tier. Possible values are Free ou Paid"
  type        = string
  default     = "Free"
}

variable "default_agent_profile_name" {
  description = "default_agent_profile_name"
  type        = string
  default     = null
}

variable "default_agent_profile_count" {
  description = "default_agent_profile_count"
  type        = number
  default     = null
}

variable "default_agent_profile_vmsize" {
  description = "default_agent_profile_vmsize"
  type        = string
  default     = null
}

variable "default_agent_profile_ostype" {
  description = "default_agent_profile_ostype"
  type        = string
  default     = null
}

variable "default_agent_profile_availability_zones" {
  description = "default_agent_profile_availability_zones"
  type        = any
  default     = null
}

variable "default_agent_profile_enable_auto_scaling" {
  description = "default_agent_profile_enable_auto_scaling"
  type        = bool
  default     = null
}

variable "default_agent_profile_min_count" {
  description = "default_agent_profile_min_count"
  type        = number
  default     = null
}

variable "default_agent_profile_max_count" {
  description = "default_agent_profile_max_count"
  type        = number
  default     = null
}

variable "default_agent_profile_vmtype" {
  description = "default_agent_profile_vmtype"
  type        = string
  default     = null
}

variable "default_agent_profile_node_taints" {
  description = "default_agent_profile_node_taints"
  type        = any
  default     = null
}

variable "default_agent_profile_nodes_subnet_id" {
  description = "default_agent_profile_nodes_subnet_id"
  type        = any
  default     = null
}

variable "default_agent_profile_max_pods" {
  description = "default_agent_profile_max_pods"
  type        = number
  default     = null
}

variable "default_agent_profile_osdisk_type" {
  description = "default_agent_profile_osdisk_type"
  type        = string
  default     = null
}

variable "default_agent_profile_osdisk_size" {
  description = "default_agent_profile_osdisk_size"
  type        = string
  default     = null
}

variable "default_agent_profile_enable_node_public_ip" {
  description = "default_agent_profile_enable_node_public_ip"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = <<EOD
Default node pool configuration:
```
map(object({
    name                  = string
    count                 = number
    vm_size               = string
    os_type               = string
    availability_zones    = list(number)
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    type                  = string
    node_taints           = list(string)
    vnet_subnet_id        = any
    max_pods              = number
    os_disk_type          = string
    os_disk_size_gb       = number
    enable_node_public_ip = bool
}))
```
EOD

  type    = map(any)
  default = {}
}

variable "addons" {
  description = "Kubernetes addons to enable /disable"
  type = object({
    policy = bool
  })
  default = {
    policy = false
  }
}

variable "oms_agent" {
  description = "Kubernetes addons to enable /disable"
  default     = null

  type = object({
    enable_oms_agent       = optional(bool),
    oms_agent_workspace_id = optional(string),
  })
}

variable "enable_log_workspace" {
  description = "Kubernetes enable /disable creating Conainer Insights Solution"
  type        = bool
  default     = false
}


variable "rbac_enabled" {
  description = "Whether Role Based Access Control for the Kubernetes Cluster should be enabled. Defaults to true. Changing this forces a new resource to be created."
  default     = true
}

variable "azure_active_directory_role_based_access_control" {
  description = "managed - (Optional) Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration.  && azure_rbac_enabled  Is Role Based Access Control based on Azure AD enabled? & admin_group_object_ids - (Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = null

  type = object({
    azure_rbac_managed     = optional(bool),
    azure_rbac_enabled     = optional(bool),
    admin_group_object_ids = optional(list(any)),
  })
}

variable "linux_profile" {
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
  type = object({
    username = string,
    #ssh_key  = string
  })
  default = null
}

variable "service_cidr" {
  description = "CIDR used by kubernetes services (kubectl get svc)."
  type        = string
}

variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
  type        = string
  default     = "loadBalancer"
}

variable "docker_bridge_cidr" {
  description = "IP address for docker with Network CIDR."
  type        = string
  default     = "172.16.0.1/16"
}

variable "nodes_pools" {
  description = "A list of nodes pools to create, each item supports same properties as `local.default_agent_profile`"
  #type        = list(any)

}

variable "container_registries_id" {
  description = "List of Azure Container Registries ids where AKS needs pull access."
  #type        = list(any)
  #default     = []
}

variable "depends" {
  description = "depends_on"
  type        = any
}

variable "workspace_id" {
  description = "The log analytics workspace id"
  type        = string
  default     = null
}

variable "workspace_name" {
  description = "The log analytics workspace name"
  type        = string
  default     = null
}
