variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) default = {} }
variable "public_network_access" { type = string default = "Enabled" }
variable "identity_type" { type = string default = "SystemAssigned" }
