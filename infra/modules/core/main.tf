terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_analytics_sku
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_key_vault" "kv" {
  count               = var.enable_key_vault ? 1 : 0
  name                = replace(lower("${var.name}kv"), "-", "")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enable_rbac_authorization = true
  purge_protection_enabled = true
  soft_delete_retention_days = 7
  tags = var.tags
}

data "azurerm_client_config" "current" {}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "kv_pe" {
  count               = var.enable_key_vault && var.enable_kv_private_endpoint && var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "${var.name}-kv-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv[0].id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_zone_group" "kv_pdns" {
  count               = var.enable_key_vault && var.enable_kv_private_endpoint && var.private_endpoint_subnet_id != null && length(var.private_dns_zone_ids) > 0 ? 1 : 0
  name                = "${var.name}-kv-dns"
  private_endpoint_id = azurerm_private_endpoint.kv_pe[0].id

  dynamic "private_dns_zone_configs" {
    for_each = var.private_dns_zone_ids
    content {
      name                = "config"
      private_dns_zone_id = each.value
    }
  }
}
