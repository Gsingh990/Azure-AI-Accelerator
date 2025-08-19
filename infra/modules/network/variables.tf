variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = list(string) default = ["10.10.0.0/16"] }
variable "subnets" {
  description = "Map of subnet name => cidr"
  type        = map(string)
  default     = { app = "10.10.1.0/24", data = "10.10.2.0/24", privatelink = "10.10.3.0/24" }
}
variable "tags" { type = map(string) default = {} }
variable "enable_private_dns" { type = bool default = true }
