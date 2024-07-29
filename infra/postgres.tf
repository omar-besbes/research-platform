resource "azurerm_postgresql_server" "efrei" {
  name                = "efrei-postgres-server"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  version                          = "11"
  administrator_login              = "adminuser"
  administrator_login_password     = "YourPassword1234!"
  storage_mb                       = 5120
  sku_name                         = "B_Gen5_1"
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_postgresql_database" "efrei" {
  name                = "efrei-db"
  resource_group_name = var.resource_group_name

  server_name = azurerm_postgresql_server.efrei.name
  charset     = "utf8"
  collation   = "en_US.UTF8"
}
