####################
# CosmosDB Modules #
####################

# Create resource groups
module "databases-rg" {
  source   = "./ResourceGroup"
  rg_name  = "pharma-databases"
  location = "East US"
}

# Create VNET 
module "Pharma-VNET" {
  source              = "./AzureNetwork/VNET"
  resource_group_name = module.databases-rg.rg_name_out
  location            = "East US"
  vnet_name           = "pharma-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_adresses     = ["10.0.1.0/24"]
  subnet_names        = ["pharma-cosmosdb-subnet"]
  service_endpoints   = [["Microsoft.AzureCosmosDB"], [""], [""]]
}

# Create CosmosDB
module "Pharma-CosmosDB" {
  source                             = "./AzureDatabases/CosmosDB"
  name                               = "pharma-cosmosdb"
  resource_group_name                = module.databases-rg.rg_name_out
  location                           = "West US"
  kind                               = "MongoDB"
  capabilities                       = ["DisableRateLimitingResponses"]
  failover_location                  = "East US"
  mongo_server_version               = 3.6
  enable_automatic_failover          = true
  zone_redundant                     = false
  enable_free_tier                   = true
  access_key_metadata_writes_enabled = false
  public_network_access              = true
  bypass_for_azure_services          = false
  virtual_network_enabled            = true
  #bypass_resources_ids              = [""]
  ip_range_filter = ["51.4.229.218", "139.217.8.252", "52.244.48.71", "104.42.195.92", "40.76.54.131", "52.176.6.30", "52.169.50.45", "52.187.184.26"]
  virtual_network_rule = {
    vnet_subnet_ids = module.Pharma-VNET.vnet_subnets[0]
  }

  capacity = {
    total_throughput_limit = 50000
  }

  backup = {
    type = "Continuous"
    #interval_in_minutes = 60
    #retention_in_hours = 8
    #storage_redundancy = Geo
  }

  databases = {
    mydb = {
      throughput     = 400
      max_throughput = null
      collections = [
        { name = "col0", shard_key = "somekey0", throughput = 1000, max_throughput = null },
        { name = "col1", shard_key = "somekey1", throughput = null, max_throughput = null }
      ]
    }
    mydb2 = {
      throughput     = null
      max_throughput = 5000
      collections    = [{ name = "col2", shard_key = "someotherkey", throughput = null, max_throughput = null }]
    }
  }

  #diagnostics = {
  #  destination   = "cosmosdbdiag"
  #  eventhub_name = "cosmosdb-diagnosticshub",
  #  logs          = ["all"],
  #  metrics       = ["all"],
  #}
}


#outputs
output "databases-rgName" {
  value = module.databases-rg.rg_name_out
}

output "databases-rgLocation" {
  value = module.databases-rg.rg_location_out
}

output "PharmaCosmosDB_id" {
  description = "The ID of the CosmosDB Account."
  value       = module.Pharma-CosmosDB.id
}

output "PharmaCosmosDB_endpoint" {
  description = "The endpoint used to connect to the CosmosDB account."
  value       = module.Pharma-CosmosDB.endpoint
}

output "PharmaCosmosDB_connection_strings" {
  description = "A list of connection strings available for this CosmosDB account."
  value       = module.Pharma-CosmosDB.connection_strings
  sensitive   = true
}

output "PharmaCosmosDB_databases" {
  description = "A map with database name with the ID for the database"
  value       = module.Pharma-CosmosDB.databases
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
