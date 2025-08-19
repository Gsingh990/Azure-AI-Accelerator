terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.113" }
    azapi   = { source = "Azure/azapi",       version = "~> 1.12" }
    azuread = { source = "hashicorp/azuread",  version = "~> 2.47" }
    random  = { source = "hashicorp/random",   version = "~> 3.6" }
  }
}
