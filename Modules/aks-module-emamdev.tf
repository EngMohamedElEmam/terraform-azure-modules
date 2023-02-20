#######################
# AKS Cluster Modules #
#######################
# Create resource groups
module "aksemam-rg-local" {
  source   = "./ResourceGroup"
  rg_name  = "DevOps-Dev"
  location = "East US"
}

# Create ACR for AKS-pharmav3
module "ASKemam-ACR-local" {
  source              = "./AzureACR"
  resource_group_name = module.aksemam-rg-local.rg_name_out
  location            = "East US"
  acr_name            = "aksemamacrlocal"
  admin_enabled       = true
  sku                 = "Standard"
}

# Create VNET for AKS-pharmav3
module "ASKemam-VNET-local" {
  source              = "./AzureNetwork/VNET"
  resource_group_name = module.aksemam-rg-local.rg_name_out
  location            = "East US"
  vnet_name           = "aksemam-local-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_adresses     = ["10.0.0.0/20"]
  subnet_names        = ["aksemam-nodes-subnet"]
  service_endpoints   = [["Microsoft.Storage"], [""], [""]]
}

#Create AKS-pharmav3 Cluster
module "AKS-emam-local" {
  source                                      = "./AzureAKS"
  resource_group_name                         = module.aksemam-rg-local.rg_name_out
  location                                    = "East US"
  prefix                                      = "cluster-local"
  kubernetes_version                          = "1.21.9"
  service_cidr                                = "10.0.16.0/22"
  rbac_enabled                                = true
  vnet_id                                     = module.ASKemam-VNET-local.vnet_id
  default_agent_profile_name                  = "systempool"
  default_agent_profile_count                 = 1
  default_agent_profile_vmsize                = "Standard_B2ms"
  default_agent_profile_ostype                = "Linux"
  default_agent_profile_availability_zones    = null
  default_agent_profile_enable_auto_scaling   = false
  default_agent_profile_min_count             = null
  default_agent_profile_max_count             = null
  default_agent_profile_vmtype                = "VirtualMachineScaleSets"
  default_agent_profile_node_taints           = null
  default_agent_profile_nodes_subnet_id       = module.ASKemam-VNET-local.vnet_subnets[0]
  default_agent_profile_max_pods              = 110
  default_agent_profile_osdisk_type           = "Managed"
  default_agent_profile_osdisk_size           = 128
  default_agent_profile_enable_node_public_ip = false
  container_registries_id                     = module.ASKemam-ACR-local.acr_id
  depends                                     = [module.ASKemam-VNET-local]


  nodes_pools = [
    {
      name                = "nodepool1"
      count               = 1
      vm_size             = "Standard_B2ms"
      os_type             = "Linux"
      os_disk_type        = "Managed"
      os_disk_size_gb     = 128
      availability_zones  = null
      enable_auto_scaling = false
      min_count           = null
      max_count           = null
      vnet_subnet_id      = module.ASKemam-VNET-local.vnet_subnets[0]
    },
  ]

  linux_profile = {
    username = "emam"
    #ssh_key  = "ssh_priv_key"
  }

  azure_active_directory_role_based_access_control = {
    azure_rbac_managed = true
    azure_rbac_enabled = true
  }

  enable_log_workspace = false

  #oms_agent = {
  #  enable_oms_agent       = true
  #  oms_agent_workspace_id = module.AKSpharmav3-LogWorkSpace-local.workspace_id
  #  policy                 = false
  #}
}



#Example showing deploying multiple assignments to different scopes with different Roles using for_each at the module.

module "RoleAssignment-local-ACR" {
  for_each = local.roleacr
  source   = "./Identity/RoleAssignmentAD"

  role_definition_name = each.key
  scope_id             = module.ASKemam-ACR-local.acr_id
  principal_ids        = each.value
  depends              = [module.ASKemam-ACR-local.acr_id]
}

module "RoleAssignment-local-aks" {
  for_each = local.roleaks
  source   = "./Identity/RoleAssignmentAD"

  role_definition_name = each.key
  scope_id             = module.AKS-emam-local.aks_id
  principal_ids        = each.value
  depends              = [module.AKS-emam-local.aks_id]
}


#Outputs
output "aks-rgName" {
  value = module.aksemam-rg-local.rg_name_out
}

output "aks_id" {
  description = "AKS resource id"
  value       = module.AKS-emam-local.aks_id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = module.AKS-emam-local.aks_name
}

output "aks_nodes_pools_ids" {
  description = "Ids of AKS nodes pools"
  value       = module.AKS-emam-local.aks_nodes_pools_ids
}

output "aks_nodes_pools_names" {
  description = "Names of AKS nodes pools"
  value       = module.AKS-emam-local.aks_nodes_pools_names
}

output "aks_user_managed_identity" {
  value       = module.AKS-emam-local.aks_user_managed_identity
  description = "The User Managed Identity used by AKS Agents"
}

output "acr_id" {
  description = "The Container Registry ID."
  value       = module.ASKemam-ACR-local.acr_id
}

output "acr_name" {
  description = "The Container Registry name."
  value       = module.ASKemam-ACR-local.acr_name
}

output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = module.ASKemam-ACR-local.login_server
}

output "acr_fqdn" {
  description = "The Container Registry FQDN."
  value       = module.ASKemam-ACR-local.acr_fqdn
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = module.ASKemam-ACR-local.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled."
  value       = module.ASKemam-ACR-local.admin_password
  sensitive   = true
}
