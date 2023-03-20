terraform {
  backend "azurerm" {
    resource_group_name  = "terrform-mgmt"
    storage_account_name = "pharmatfstate"
    container_name       = "tf-state"
    key                  = "local.dev.tfstate"
  }
}
