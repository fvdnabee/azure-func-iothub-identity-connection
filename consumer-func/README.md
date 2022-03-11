# Azure function for consuming EH/IoT hub events
## Create new Function App project
```
func init consumer-func --worker-runtime node --language javascript --source-control
```

## Create new function for IoT hub
```
func new --name iothub-events-func --template "IoT Hub (Event Hub)"
```

## Microsoft tutorial on Azure IoT hub trigger for Azure Functions
See [Azure IoT Hub trigger for Azure
Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-iot-trigger?tabs=javascript).

## Azure functions extension bundle 4.0.0 preview
See release
[here](https://github.com/Azure/azure-functions-extension-bundles/releases/tag/preview-4.0.0).

## Authenticating to services from Azure Functions
### Connect to IoT hub using a managed identity
As per the Microsoft documentation, the Event Hubs extension 5.x and higher
supports connecting to an IoT hub via an identity rather than a secret. Should
be interesting if we want to get rid of connection strings. More details
[here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs#event-hubs-extension-5x-and-higher).

See also [Configure an identity-based
connection](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=eventhubs#configure-an-identity-based-connection).

It is expected to use a system-assigned identity on the Azure Functions service.
