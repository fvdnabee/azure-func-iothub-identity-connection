module.exports = function (context, IoTHubMessages) {
    context.log(`JavaScript eventhub trigger function called for message array: ${IoTHubMessages}`);

    IoTHubMessages.forEach((message, index) => {
        /* Iterating over the telemetry messages and accessing system properties array for IoT Hub message headers
        docs: https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs-trigger?tabs=javascript
        */
        context.log(`Processed message ${message}`);
    });

    context.done();
};
