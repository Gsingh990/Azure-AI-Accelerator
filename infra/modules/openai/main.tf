terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
    azapi   = { source = "Azure/azapi" }
  }
}

resource "azurerm_cognitive_account" "openai" {
  name                = "${var.name}-aoai"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name
  public_network_access_enabled = var.public_network_access == "Enabled"
  tags                         = var.tags
}

# Optional model deployments via azapi (until full provider support exists)
resource "azapi_resource" "deployments" {
  for_each  = var.deployments
  type      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name      = each.key
  parent_id = azurerm_cognitive_account.openai.id
  body = jsonencode({
    properties = {
      model = {
        format  = each.value.model_format
        name    = each.value.model_name
        version = each.value.model_version
      }
      raiPolicyName = null
      capacity = coalesce(try(each.value.capacity, null), null)
      scaleSettings = {
        scaleType = try(each.value.scale_type, "Standard")
      }
    }
  })
}

# Private Endpoint for Azure OpenAI (Cognitive Services)
resource "azurerm_private_endpoint" "aoai_pe" {
  count               = var.enable_private_endpoint && var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "${var.name}-aoai-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-aoai-psc"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
}

resource "azurerm_private_dns_zone_group" "aoai_pdns" {
  count               = var.enable_private_endpoint && var.private_endpoint_subnet_id != null && length(var.private_dns_zone_ids) > 0 ? 1 : 0
  name                = "${var.name}-aoai-dns"
  private_endpoint_id = azurerm_private_endpoint.aoai_pe[0].id

  dynamic "private_dns_zone_configs" {
    for_each = var.private_dns_zone_ids
    content {
      name                 = "config-${replace(each.value, "/", "-")}"
      private_dns_zone_id  = each.value
    }
  }
}
