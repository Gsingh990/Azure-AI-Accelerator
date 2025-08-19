resource "azurerm_storage_account" "sa" {
  name                     = replace(lower(var.name), "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.account_kind
  account_tier             = split("_", var.sku)[0]
  account_replication_type = split("_", var.sku)[1]
  is_hns_enabled           = var.enable_hns
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_private_endpoint" "blob_pe" {
  count               = var.enable_private_endpoint && var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "${var.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_zone_group" "blob_pdns" {
  count               = var.enable_private_endpoint && var.private_endpoint_subnet_id != null && length(var.private_dns_zone_ids) > 0 ? 1 : 0
  name                = "${var.name}-blob-dns"
  private_endpoint_id = azurerm_private_endpoint.blob_pe[0].id

  dynamic "private_dns_zone_configs" {
    for_each = var.private_dns_zone_ids
    content {
      name                = "config"
      private_dns_zone_id = each.value
    }
  }
}
