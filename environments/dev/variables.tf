variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "api_app_name" {
  type = string
}

variable "frontend_app_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "access_tier" {
  type    = string
  default = "Hot"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "containers" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sql_server_name" {}
variable "database_name" {}

variable "admin_login" {}

variable "admin_password" {
  sensitive = true
}

variable "sku_name" {}

variable "resource_group_name" {}
variable "location" {}

variable "key_vault_name" {}

variable "sql_server_name" {}
variable "database_name" {}

variable "sql_sku" {}