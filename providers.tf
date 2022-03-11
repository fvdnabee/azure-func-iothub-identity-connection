terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = "~> 1.1.0"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.98.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Our principal does not have authorization to perform action
      # 'Microsoft.KeyVault/locations/deletedVaults/purge/action' over a
      # subscription scope
      purge_soft_delete_on_destroy = false
    }
  }

  skip_provider_registration = true
}
