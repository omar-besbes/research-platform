resource "azurerm_storage_account" "efrei" {
  name                = "efreistorageaccount"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
