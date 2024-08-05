data "azurerm_container_registry" "efrei" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# Give AKS access to pull images from ACR
resource "azurerm_role_assignment" "efrei" {
  principal_id         = var.principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.efrei.id
}
