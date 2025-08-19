resource "azurerm_service_plan" "plan" {
  name                = "${var.name}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.plan_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "apps" {
  for_each            = var.apps
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id
  site_config {
    linux_fx_version = each.value.runtime
  }
  https_only = true
  tags       = var.tags

  identity {
    type = var.enable_identity ? "SystemAssigned" : "None"
  }
}
