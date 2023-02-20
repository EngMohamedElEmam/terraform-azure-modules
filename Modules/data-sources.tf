data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

# Import resource groups
data "azurerm_resource_group" "devops" {
  name = "DevOps"
}

data "azuread_user" "emam" {
  user_principal_name = "mohamed.elemam@pharma.org"
}
