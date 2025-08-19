variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "plan_sku" { type = string default = "P1v3" }
variable "apps" {
  description = "Map of app_key => { name, runtime } where runtime is LinuxFxVersion (e.g., 'NODE|18-lts')"
  type = map(object({ name = string, runtime = string }))
  default = {}
}
variable "tags" { type = map(string) default = {} }
variable "enable_identity" { type = bool default = true }
