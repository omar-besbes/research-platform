resource "azurerm_postgresql_flexible_server" "efrei" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                       = var.pg_version
  delegated_subnet_id           = data.azurerm_subnet.efrei.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false
  administrator_login           = var.pg_credentials.username
  administrator_password        = var.pg_credentials.password
  storage_mb                    = var.pg_storage_size
  sku_name                      = "B_Standard_B1ms"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
}

# resource "azurerm_postgresql_database" "efrei" {
#   name                = "efrei-db"
#   resource_group_name = var.resource_group_name

#   server_name = azurerm_postgresql_flexible_server.efrei.name
#   charset     = "utf8"
#   collation   = "en_US.UTF8"
# }
