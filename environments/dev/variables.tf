variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "log_analytics_name" {
  type = string
}

variable "app_insights_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "sql_sku" {
  type = string
}

variable "api" {
  type = object({
    app_name     = string
    node_version = string
    app_settings = map(string)
  })
}

variable "frontend" {
  type = object({
    app_name     = string
    node_version = string
    api_url      = string
    app_settings = map(string)
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}