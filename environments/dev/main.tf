#################################################
# DATA SOURCES
#################################################

data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = module.key_vault.id
}

#################################################
# RESOURCE GROUP
#################################################

module "resource_group" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/resource-group?ref=main"

  resource_group_name = var.resource_group_name
  location            = var.location
}

#################################################
# LOG ANALYTICS
#################################################

module "monitoring" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/monitoring?ref=main"

  workspace_name   = var.log_analytics_name
  app_insights_name = var.app_insights_name

  resource_group_name = module.resource_group.name
  location            = var.location

  tags = local.tags
}

#################################################
# NETWORK
#################################################

module "network" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/network?ref=main"

  resource_group_name = module.resource_group.name
  location            = var.location

  vnet_name = var.vnet_name

  address_space = [
    "10.10.0.0/16"
  ]
}

#################################################
# KEY VAULT
#################################################

module "key_vault" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/key-vault?ref=main"

  key_vault_name      = var.key_vault_name
  resource_group_name = module.resource_group.name
  location            = var.location

  tenant_id = data.azurerm_client_config.current.tenant_id

  tags = local.tags
}

#################################################
# STORAGE ACCOUNT
#################################################

module "storage" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/storage?ref=main"

  storage_account_name = var.storage_account_name

  resource_group_name = module.resource_group.name
  location            = var.location

  tags = local.tags
}

#################################################
# SQL SERVER
#################################################

module "mssql" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/mssql?ref=main"

  sql_server_name = var.sql_server_name
  database_name   = var.database_name

  resource_group_name = module.resource_group.name
  location            = var.location

  admin_login    = "sqladmin"
  admin_password = data.azurerm_key_vault_secret.sql_password.value

  sku_name = var.sql_sku

  tags = local.tags

  depends_on = [
    module.key_vault
  ]
}

#################################################
# PRIVATE ENDPOINTS
#################################################
module "private_endpoint_sql" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/private-endpoint?ref=main"

  name                = "pep-sql-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id          = module.network.private_endpoint_subnet_id
  target_resource_id = module.mssql.sql_server_id

  subresource_names = [
    "sqlServer"
  ]

  tags = local.tags

  depends_on = [
    module.network,
    module.mssql
  ]
}

module "private_endpoint_storage" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/private-endpoint?ref=main"

  name                = "pep-storage-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id          = module.network.private_endpoint_subnet_id
  target_resource_id = module.storage.storage_account_id

  subresource_names = [
    "blob"
  ]

  tags = local.tags

  depends_on = [
    module.network,
    module.storage
  ]
}

module "private_endpoint_kv" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/private-endpoint?ref=main"

  name                = "pep-kv-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  subnet_id          = module.network.private_endpoint_subnet_id
  target_resource_id = module.key_vault.id

  subresource_names = [
    "vault"
  ]

  tags = local.tags

  depends_on = [
    module.network,
    module.key_vault
  ]
}

#################################################
# APP SERVICE PLAN
#################################################

module "service_plan" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/service-plan?ref=main"

  service_plan_name   = var.service_plan_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

#################################################
# APP SERVICES
#################################################
module "appservice" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/appservice?ref=main"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  service_plan_id = module.service_plan.id

  api_subnet_id      = module.network.api_subnet_id
  frontend_subnet_id = module.network.frontend_subnet_id

  environment = var.environment

  api      = var.api
  frontend = var.frontend

  tags = local.tags
}

#################################################
# DIAGNOSTIC SETTINGS
#################################################

module "diagnostic_api" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/diagnostic-settings?ref=main"

  name                       = "diag-api-${var.environment}"
  target_resource_id         = module.appservice.api_id
  log_analytics_workspace_id = module.monitoring.log_analytics_id

  enabled_log_categories = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServicePlatformLogs"
  ]

  enabled_metric_categories = [
    "AllMetrics"
  ]
}

module "diagnostic_frontend" {
  source = "git::https://github.com/moraes-caroline/iac-modules-azure.git//infra/modules/diagnostic-settings?ref=main"

  name                       = "diag-front-${var.environment}"
  target_resource_id         = module.appservice.frontend_id
  log_analytics_workspace_id = module.monitoring.log_analytics_id

  enabled_log_categories = [
  "AppServiceHTTPLogs",
  "AppServiceConsoleLogs",
  "AppServiceAppLogs",
  "AppServiceAuditLogs",
  "AppServicePlatformLogs"
  ]

  enabled_metric_categories = [
    "AllMetrics"
  ]
}