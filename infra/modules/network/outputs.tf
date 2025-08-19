output "vnet_id" { value = azurerm_virtual_network.vnet.id }
output "vnet_name" { value = azurerm_virtual_network.vnet.name }
output "subnet_ids" { value = { for k, s in azurerm_subnet.subnets : k => s.id } }
output "cognitive_dns_zone_id" { value = try(azurerm_private_dns_zone.cognitive[0].id, null) }
output "vault_dns_zone_id" { value = try(azurerm_private_dns_zone.vault[0].id, null) }
output "blob_dns_zone_id" { value = try(azurerm_private_dns_zone.blob[0].id, null) }
