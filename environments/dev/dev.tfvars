# App Service API
api = {
  app_name     = "app-api-dev"
  node_version = "20-lts"
  always_on    = true

  app_settings = {
    NODE_ENV = "development"
  }
}

# App Service FRONT END
frontend = {
  app_name     = "app-front-dev"
  node_version = "20-lts"
  always_on    = true

  api_url = "https://app-api-dev.azurewebsites.net"

  app_settings = {
    NODE_ENV = "development"
  }
}

# Storage Account 
storage_account_name = "stgdev01"
location = "Brazil South"

# SQL Server 
resource_group_name = "rg-dev"
key_vault_name = "kv-dev"

sql_server_name = "sql-server-dev"
database_name = "db-server-dev"
sql_sku = "S2"