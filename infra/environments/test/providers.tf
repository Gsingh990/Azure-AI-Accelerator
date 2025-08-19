provider "azurerm" {
  features {}
}

#terraform {
#  backend "azurerm" {
#    resource_group_name  = "tfstate-rg"
#    storage_account_name = "<yourstateaccount>"
#    container_name       = "tfstate"
#    key                  = "test.tfstate"
#  }
#}
