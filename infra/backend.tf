# backend.tf
resource "azurerm_container_group" "backend" {
  name                = "efrei-backend-cg"
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
    name   = "backend"
    image  = "${var.registry}/backend:latest"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 3011
      protocol = "TCP"
    }
    environment_variables = {
      NODE_ENV               = "development"
      DB_URI                 = "postgres://efrei:secret@db:5432/db"
      ELASTICSEARCH_NODE     = "http://elasticsearch:9200"
      FRONTEND_URL           = "http://frontend:3000"
      MINIO_WRAPPER_WS_URL   = "ws://localhost:1206"
      MINIO_WRAPPER_HTTP_URL = "http://wrapper:1206"
    }
  }

  image_registry_credential {
    server                    = var.registry
    user_assigned_identity_id = azurerm_user_assigned_identity.efrei.id
  }
}
