resource "azurerm_container_group" "go_wrapper" {
  name                = "efrei-go-wrapper-cg"
  location            = data.azurerm_resource_group.efrei.location
  resource_group_name = var.resource_group_name

  ip_address_type = "Public"
  os_type         = "Linux"
  sku             = "Standard"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.efrei.id]
  }

  container {
    name   = "go-wrapper"
    image  = "${var.registry}/go-wrapper:latest"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 1206
      protocol = "TCP"
    }
    environment_variables = {
      MINIO_ENDPOINT   = "http://minio:9000"
      MINIO_ACCESS_KEY = "minioadmin"
      MINIO_SECRET_KEY = "minioadmin"
    }
  }

  image_registry_credential {
    server                    = var.registry
    user_assigned_identity_id = azurerm_user_assigned_identity.efrei.id
  }
}
