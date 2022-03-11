locals {
  resource_name_suffix = "fxiothubmsi${random_string.suffix.result}"

  event_hub_name = var.consume_iothub ? azurerm_iothub.my_hub.name : azurerm_eventhub.my_hub.name
  event_hub_ns = var.consume_iothub ? azurerm_iothub.my_hub.event_hub_events_namespace : azurerm_eventhub.my_hub.namespace_name
  event_hub_fqns = "${local.event_hub_ns}.servicebus.windows.net"

  tags = merge(var.tags, { terraform_module = "azure-func-iothub-identity-connection" })
}
