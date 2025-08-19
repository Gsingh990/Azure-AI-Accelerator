provider "azurerm" {
  features {}
}

# To use remote state, uncomment and fill values:
#terraform {
#  backend "azurerm" {
#    resource_group_name  = "tfstate-rg"
#    storage_account_name = "<yourstateaccount>"
#    container_name       = "tfstate"
#    key                  = "dev.tfstate"
#  }
#}
