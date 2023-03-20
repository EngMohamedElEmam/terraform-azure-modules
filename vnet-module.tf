/* ################
# VNET Modules #
################

module "Pharma-VNET" {
  source              = "./AzureNetwork/VNET"
  resource_group_name = module.network-rg.rg_name_out
  location            = "East US"
  vnet_name           = "pharma-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_adresses     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]
  service_endpoints   = [["Microsoft.AzureCosmosDB"], [""], [""]]
}


#outputs
output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = module.Pharma-VNET.vnet_id
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = module.Pharma-VNET.vnet_name
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = module.Pharma-VNET.vnet_address_space
}

output "vnet_subnets" {
  description = "The ids of subnets created inside the newl vNet"
  value       = module.Pharma-VNET.vnet_subnets
}
 */
