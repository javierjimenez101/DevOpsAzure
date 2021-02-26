#########################################################################
#                                                                       #
# Configuración principal para Terraform                                #
#                                                                       #
#########################################################################


# Configuración del provider de Azure para la creación de la infraestructura.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.1"
    }
  }
}

# Datos de subscripción y autenticación en Azure
provider "azurerm" {
  features {}
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}

# Resource group en el que agrupar todos los recursos a crear.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "unirRG" {
    name     =  "unirresourcegroup"
    location = var.location

    tags = {
        environment = "UNIR"
    }

}

# Storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "stAccount" {
    name                     = "unirstorageaccount" 
    resource_group_name      = azurerm_resource_group.unirRG.name
    location                 = azurerm_resource_group.unirRG.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    tags = {
        environment = "UNIR"
    }

}

# Referencia a archivo para la configuración del usuario del S.O.
data "template_file" "user_data" {
  template = file("user_config.yaml")
}