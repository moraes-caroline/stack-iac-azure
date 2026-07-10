# Key Vault
module "key_vault" {
  source = "../../modules/key-vault"

  key_vault_name     = var.key_vault_name
  resource_group_name = module.resource_group.name
  location            = var.location

  tenant_id = data.azurerm_client_config.current.tenant_id

  tags = local.tags
}

# Resource group
module "resource_group" {
    source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/resource-group?ref=main"

  resource_group_name = var.resource_group_name
  location            = var.location
}

# Service Plan
module "service_plan" {
    source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/service-plan?ref=main"

  service_plan_name   = var.service_plan_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

#App Service
module "appservice" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/appservice?ref=main"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  service_plan_id     = module.service_plan.id

  environment = var.environment

  api      = var.api
  frontend = var.frontend

  tags = var.tags
}

# Storage Account
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# SQL Server
module "mssql" {
  source = "../../modules/mssql"

  sql_server_name     = var.sql_server_name
  database_name       = var.database_name

  resource_group_name = module.resource_group.name
  location            = var.location

  admin_login = "sqladmin"

  admin_password = data.azurerm_key_vault_secret.sql_password.value

  sku_name = var.sql_sku

  tags = local.tags
}