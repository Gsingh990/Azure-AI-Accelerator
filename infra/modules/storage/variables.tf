variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "account_kind" { type = string default = "StorageV2" }
variable "sku" { type = string default = "Standard_LRS" }
variable "enable_hns" { type = bool default = false }
variable "tags" { type = map(string) default = {} }
variable "enable_private_endpoint" { type = bool default = true }
variable "private_endpoint_subnet_id" { type = string, nullable = true, default = null }
variable "private_dns_zone_ids" { type = list(string), default = [] }
