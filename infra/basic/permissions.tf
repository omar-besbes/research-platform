# Grant permission for container apps to pull images from ACR
resource "azurerm_user_assigned_identity" "efrei" {
  name                = "efrei-usrid"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.efrei.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.efrei.principal_id
}

data "azurerm_container_registry" "efrei" {
  name                = "efrei"
  resource_group_name = var.resource_group_name
}
