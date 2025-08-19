variable "name" { description = "Base name/prefix" type = string }
variable "location" { description = "Azure region" type = string default = "eastus" }
variable "tags" { type = map(string) default = { environment = "prod" } }

variable "enable_app_hosting" { type = bool default = false }

variable "openai_deployments" {
  description = "Map of Azure OpenAI deployments"
  type = map(object({
    model_format  = string
    model_name    = string
    model_version = string
    scale_type    = optional(string, "Standard")
    capacity      = optional(number)
  }))
  default = {
    "gpt-4o" = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o"
      model_version = "2024-05-01"
      scale_type    = "Standard"
    }
  }
}
