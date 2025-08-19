variable "name" { description = "Base name/prefix for resources" type = string }
variable "location" { description = "Azure region" type = string }
variable "tags" { description = "Common tags" type = map(string) default = {} }
variable "log_analytics_sku" { type = string default = "PerGB2018" }
variable "enable_key_vault" { type = bool default = true }
variable "diagnostics_enabled" { type = bool default = true }
variable "enable_kv_private_endpoint" { type = bool default = true }
variable "private_endpoint_subnet_id" { type = string, nullable = true, default = null }
variable "private_dns_zone_ids" { type = list(string), default = [] }
