####################
# Linux VM Modules #
####################

# Create resource group
module "Linux-VM-rg" {
  source   = "./ResourceGroup"
  rg_name  = "IaaS-vm"
  location = "East US"
}

# Create VNET for Linux-VM
module "Linux-VM-VNET-local" {
  source              = "./AzureNetwork/VNET"
  resource_group_name = module.Linux-VM-rg.rg_name_out
  location            = module.Linux-VM-rg.rg_location_out
  vnet_name           = "linuxvm-local-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_adresses     = ["10.0.0.0/20"]
  subnet_names        = ["linuxvm-subnet"]
  service_endpoints   = [["Microsoft.Storage"], [""], [""]]
}

#Create Linux VM
module "Linux-VM-local" {
  source                    = "./VirtualMachine/AzureVM"
  resource_group_name       = module.Linux-VM-rg.rg_name_out
  location                  = module.Linux-VM-rg.rg_location_out
  virtual_network_name      = module.Linux-VM-VNET-local.vnet_name
  nic_subnet_id             = module.Linux-VM-VNET-local.vnet_subnets[0]
  nsg_subnet_address_prefix = module.Linux-VM-VNET-local.vnet_address_space
  virtual_machine_name      = "vm-linux"
  domain_name_label         = ["tpaytest", "tpaytest2", "tpaytest3"]

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password 
  # To generate SSH key pair, specify `generate_admin_ssh_key = true`
  # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.  
  os_flavor               = "linux"
  linux_distribution_name = "rhel84-gen2" #"ubuntu2004-gen2"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 3

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = true
  enable_vm_availability_set       = true
  enable_public_ip_address         = true
  public_ip_availability_zone      = [2]

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  nsg_inbound_rules = [
    {
      name                   = "ssh"
      destination_port_range = "22"
      source_address_prefix  = "*"
      protocol               = "Tcp"
      source_port_range      = "*"
      access                 = "Allow"
    },
    {
      name                   = "http"
      destination_port_range = "80"
      source_address_prefix  = "*"
      protocol               = "Tcp"
      source_port_range      = "*"
      access                 = "Deny"
    },
  ]

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = true

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  #deploy_log_analytics_agent                 = true
  #log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
  #log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

}


# outputs
output "rg_name" {
  value = module.Linux-VM-rg.rg_name_out
}

output "rg_location" {
  value = module.Linux-VM-rg.rg_location_out
}

output "vnet_name" {
  value = module.Linux-VM-VNET-local.vnet_name
}

output "vnet_subnets" {
  value = module.Linux-VM-VNET-local.vnet_subnets
}

output "vnet_subnets_address_prefix" {
  value = module.Linux-VM-VNET-local.vnet_address_space
}

output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = module.Linux-VM-local.admin_ssh_key_public
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = module.Linux-VM-local.admin_ssh_key_private
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  sensitive   = true
  value       = module.Linux-VM-local.linux_vm_password
}

output "linux_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = module.Linux-VM-local.linux_vm_public_ips
}

output "linux_vm_private_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = module.Linux-VM-local.linux_vm_private_ips
}

output "linux_virtual_machine_ids" {
  description = "The resource id's of all Linux Virtual Machine."
  value       = module.Linux-VM-local.linux_virtual_machine_ids
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = module.Linux-VM-local.network_security_group_ids
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine availability set"
  value       = module.Linux-VM-local.vm_availability_set_id
}
