output "funcapp_name" {
  description = "Name of the created function app"
  value = azurerm_windows_function_app.funcapp.name
}
