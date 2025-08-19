terraform {
  required_providers {
    azapi = { source = "Azure/azapi" }
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "hub" {
  type      = "Microsoft.CognitiveServices/aiHubs@2024-05-01-preview"
  name      = "${var.name}-aihub"
  location  = var.location
  parent_id = data.azurerm_resource_group.rg.id
  identity  = {
    type = var.identity_type
  }
  tags = var.tags
  body = jsonencode({
    properties = {
      publicNetworkAccess = var.public_network_access
    }
  })
}

resource "azapi_resource" "project" {
  type      = "Microsoft.CognitiveServices/aiHubs/projects@2024-05-01-preview"
  name      = "${var.name}-project"
  location  = var.location
  parent_id = azapi_resource.hub.id
  tags      = var.tags
  body = jsonencode({
    properties = {
      publicNetworkAccess = var.public_network_access
    }
  })
}
