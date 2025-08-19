locals { rg_name = "${var.name}-test" }

module "core" {
  source   = "../../modules/core"
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source              = "../../modules/network"
  name                = local.rg_name
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  count               = module.core.key_vault_id == null ? 0 : 1
  name                = "${local.rg_name}-kv-pe"
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  subnet_id           = module.network.subnet_ids["privatelink"]

  private_service_connection {
    name                           = "${local.rg_name}-kv-psc"
    private_connection_resource_id = module.core.key_vault_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_zone_group" "kv_pdns" {
  count               = module.core.key_vault_id == null ? 0 : 1
  name                = "${local.rg_name}-kv-dns"
  private_endpoint_id = azurerm_private_endpoint.kv_pe[0].id

  private_dns_zone_configs { name = "config" private_dns_zone_id = module.network.vault_dns_zone_id }
}

module "storage" {
  source              = "../../modules/storage"
  name                = "${var.name}datatest"
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  tags                = var.tags
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.network.subnet_ids["privatelink"]
  private_dns_zone_ids       = compact([module.network.blob_dns_zone_id])
}

module "ai_foundry" {
  source              = "../../modules/ai_foundry"
  name                = local.rg_name
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  tags                = var.tags
}

module "openai" {
  source              = "../../modules/openai"
  name                = local.rg_name
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  tags                = var.tags
  deployments               = var.openai_deployments
  enable_private_endpoint   = true
  private_endpoint_subnet_id = module.network.subnet_ids["privatelink"]
  private_dns_zone_ids      = compact([module.network.cognitive_dns_zone_id])
}

module "app" {
  count               = var.enable_app_hosting ? 1 : 0
  source              = "../../modules/app"
  name                = local.rg_name
  location            = module.core.location
  resource_group_name = module.core.resource_group_name
  tags                = var.tags
  apps = {
    backend = { name = "${var.name}-api-test", runtime = "NODE|18-lts" }
    frontend = { name = "${var.name}-web-test", runtime = "NODE|18-lts" }
  }
}

output "resource_group"   { value = module.core.resource_group_name }
output "ai_hub"           { value = module.ai_foundry.hub_name }
output "ai_project"       { value = module.ai_foundry.project_name }
output "openai_endpoint"  { value = module.openai.endpoint }
