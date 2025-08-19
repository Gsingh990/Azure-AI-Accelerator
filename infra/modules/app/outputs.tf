output "plan_id" { value = azurerm_service_plan.plan.id }
output "app_ids" { value = { for k, a in azurerm_linux_web_app.apps : k => a.id } }
output "principal_ids" { value = { for k, a in azurerm_linux_web_app.apps : k => try(a.identity[0].principal_id, null) } }
