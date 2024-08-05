resource "azurerm_private_dns_zone" "postgres" {
  name                = "efrei.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                = "efrei-netlink"
  resource_group_name = var.resource_group_name

  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = data.azurerm_virtual_network.efrei.id
  depends_on            = [data.azurerm_subnet.efrei]
}
