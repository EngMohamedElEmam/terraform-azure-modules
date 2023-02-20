locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
}

resource "azurerm_resource_group" "example" {
  name     = "${var.rg_name}RG"
  location = var.location

  tags = local.common_tags
}
