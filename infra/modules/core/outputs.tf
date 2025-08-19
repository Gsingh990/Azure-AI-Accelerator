output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "resource_group_id" { value = azurerm_resource_group.rg.id }
output "location" { value = azurerm_resource_group.rg.location }
output "log_analytics_id" { value = azurerm_log_analytics_workspace.law.id }
output "key_vault_id" { value = try(azurerm_key_vault.kv[0].id, null) }
output "key_vault_name" { value = try(azurerm_key_vault.kv[0].name, null) }
