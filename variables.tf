variable "resource_group_name" {
  description = "Name of the resource group to deploy module in."
  nullable    = false
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group to deploy module in."
  nullable    = false
  type        = string
  default     = "West Europe"
}

variable "connection_name_prefix" {
  description = "The value of the connection property in the function's EH/IoT hub trigger binding definition."
  nullable    = false
  type        = string
  default     = "iotHubTriggerAppSettingsPrefix"
}

variable "tags" {
  description = "Tags to apply to all created resources."
  type        = map(string)
  default     = {}
}

variable "consume_iothub" {
  description = "Function should consume events from the iot hub, if set the false the function will consume from the event hub."
  default     = true
}
