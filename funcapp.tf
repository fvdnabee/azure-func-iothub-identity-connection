resource "azurerm_storage_account" "funcapp" {
  name                = "st${lower(local.resource_name_suffix)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_service_plan" "funcapp" {
  name                = "plan-${local.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "Y1"  # Y1: consumption SKU
  os_type = "Windows"

  tags = local.tags
}

# # Use user-assigned identity to authenticate with IoT hub:
# resource "azurerm_user_assigned_identity" "iothub" {
#   name                = "id-${local.resource_name_suffix}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#
#   tags = local.tags
# }

# Grant function access to IoT hub's builtin eventhub:
resource "azurerm_role_assignment" "funcapp" {
  scope                = azurerm_resource_group.rg.id
  # role_definition_name = "Azure Event Hubs Data Receiver"
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = azurerm_windows_function_app.funcapp.identity[0].principal_id  # System-assigned MSI
  # # Use user-assigned identity to authenticate with IoT hub:
  # principal_id         = azurerm_user_assigned_identity.iothub.principal_id  # User-assigned MSI

  skip_service_principal_aad_check = true
}

# One azurerm_application_insights resource per function app/IoT hub
resource "azurerm_application_insights" "funcapp" {
  name                = "appi-${local.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"

  tags = local.tags
}

resource "azurerm_windows_function_app" "funcapp" {
  name                = "func-${local.resource_name_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  service_plan_id = azurerm_service_plan.funcapp.id

  storage_account_name = azurerm_storage_account.funcapp.name
  storage_account_access_key = azurerm_storage_account.funcapp.primary_access_key

  identity {
    type         = "SystemAssigned"
    # # Use user-assigned identity to authenticate with IoT hub:
    # type         = "SystemAssigned, UserAssigned"
    # identity_ids = [azurerm_user_assigned_identity.iothub.id]
  }

  app_settings = {
    # Disable default landing page:
    AzureWebJobsDisableHomepage = true

    # The azurerm TF provider does not include this mandatory app setting for a
    # dynamic plan, so include WEBSITE_CONTENTAZUREFILECONNECTIONSTRING here:
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.funcapp.primary_connection_string

    # Azure diagnostics complains that FUNCTIONS_WORKER_RUNTIME is mandatory:
    # Does this have other downsides, we already set application_stack?
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~14" # Windows specific setting

    # Disable editing in Azure portal:
    FUNCTION_APP_EDIT_MODE = "readonly"

    # The iothub-events-func expects an app setting named eventHubName with the
    # name of the event hub:
    eventHubName = local.event_hub_name

    # IoT hub function binding configuration:
    # https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-iot-trigger?tabs=javascript#identity-based-connections
    "${var.connection_name_prefix}__fullyQualifiedNamespace" = local.event_hub_fqns
    # # Use user-assigned identity to authenticate with IoT hub:
    # # https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#common-properties-for-identity-based-connections
    # "${var.connection_name_prefix}__credential" = "managedidentity"
    # "${var.connection_name_prefix}__clientId"   = azurerm_user_assigned_identity.iothub.client_id

    # There appears to be a bug in the event hub binding, where the connection
    # setings are not being picked up. Prefixing the prefix with AzureWebJobs
    # might be a work around according to https://github.com/Azure/azure-sdk-for-net/issues/26663
    "AzureWebJobs${var.connection_name_prefix}__fullyQualifiedNamespace" = local.event_hub_fqns
    # # Use user-assigned identity to authenticate with IoT hub:
    # # https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#common-properties-for-identity-based-connections
    # "AzureWebJobs${var.connection_name_prefix}__credential" = "managedidentity"
    # "AzureWebJobs${var.connection_name_prefix}__clientId"   = azurerm_user_assigned_identity.iothub.client_id

    # Enable special logs for scale controller
    # See https://github.com/Azure/azure-sdk-for-net/issues/26663
    SCALE_CONTROLLER_LOGGING_ENABLED = "AppInsights:Verbose"
  }

  builtin_logging_enabled     = true
  functions_extension_version = "~4"

  site_config {
    application_stack {
      node_version = "14" # cannot use 16: expected site_config.0.application_stack.0.node_version to be one of [12 14], got 16
    }

    application_insights_connection_string = azurerm_application_insights.funcapp.connection_string
    application_insights_key               = azurerm_application_insights.funcapp.instrumentation_key
  }

  tags = local.tags
}
