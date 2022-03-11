resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# A unique suffix is assigned to all resources in this config:
resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = true
  number  = true
  special = false
}
