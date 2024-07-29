resource "azurerm_service_plan" "frontend" {
  name                = "efrei-asp"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "efrei-frontend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  service_plan_id = azurerm_service_plan.frontend.id
  https_only      = true
  app_settings = {
    BACKEND_URL            = "http://backend:3011"
    MINIO_WRAPPER_HTTP_URL = "http://wrapper:1206"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.efrei.id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.efrei.client_id

    application_stack {
      docker_image_name   = "frontend"
      docker_registry_url = "https://${var.registry}"
    }
  }
}
