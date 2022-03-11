resource "azurerm_iothub" "my_hub" {
  name                = "iot-${local.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Enable the fallback route for DeviceMessages to the IoThub's builtin events
  # endpoint:
  fallback_route {
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["events"]
    enabled        = true
  }

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = local.tags
}
