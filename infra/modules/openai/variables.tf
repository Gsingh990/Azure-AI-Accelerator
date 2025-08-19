variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "sku_name" { type = string default = "S0" }
variable "tags" { type = map(string) default = {} }
variable "public_network_access" { type = string default = "Disabled" }
variable "enable_private_endpoint" { type = bool default = true }
variable "private_endpoint_subnet_id" { type = string, nullable = true, default = null }
variable "private_dns_zone_ids" { type = list(string), default = [] }
variable "deployments" {
  description = "Map of deployment_name => { model_format, model_name, model_version, scale_type, capacity }"
  type = map(object({
    model_format  = string # e.g., OpenAI
    model_name    = string # e.g., gpt-4o, gpt-4o-mini, text-embedding-3-large
    model_version = string # e.g., 2024-05-01
    scale_type    = optional(string, "Standard")
    capacity      = optional(number)
  }))
  default = {}
}
