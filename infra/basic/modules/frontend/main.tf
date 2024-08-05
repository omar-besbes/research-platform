resource "azurerm_app_service_environment_v3" "frontend" {
  name                = "efrei-frontend-env"
  resource_group_name = var.resource_group_name

  subnet_id = data.azurerm_subnet.efrei.id
}

resource "azurerm_service_plan" "frontend" {
  name                = "efrei-frontend-sp"
  resource_group_name = var.resource_group_name
  location            = var.location

  app_service_environment_id = azurerm_app_service_environment_v3.frontend.id
  os_type                    = "Linux"
  sku_name                   = "B1"
}

resource "azurerm_linux_web_app" "frontend" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = azurerm_service_plan.frontend.id
  https_only      = true
  app_settings = {
    BACKEND_URL            = "http://${var.domain_names.backend}:3011"
    MINIO_WRAPPER_HTTP_URL = "http://${var.domain_names.go_wrapper}:1206"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.efrei.id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = data.azurerm_user_assigned_identity.efrei.client_id

    application_stack {
      docker_image_name   = "frontend"
      docker_registry_url = "https://${var.registry}"
    }
  }
}
