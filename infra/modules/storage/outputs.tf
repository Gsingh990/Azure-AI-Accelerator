output "account_id" { value = azurerm_storage_account.sa.id }
output "account_name" { value = azurerm_storage_account.sa.name }
output "primary_endpoint" { value = azurerm_storage_account.sa.primary_blob_endpoint }
