resource "azurerm_container_app" "go_wrapper" {
  name                = var.app_name
  resource_group_name = var.resource_group_name

  container_app_environment_id = data.azurerm_container_app_environment.efrei.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.efrei.id]
  }

  registry {
    server   = var.registry
    identity = data.azurerm_user_assigned_identity.efrei.id
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "go-wrapper"
      image  = "${var.registry}/go-wrapper:latest"
      cpu    = "0.75"
      memory = "1.5Gi"

      env {
        name  = "MINIO_ENDPOINT"
        value = "http://${var.domain_names.minio}:9000"
      }

      env {
        name  = "MINIO_ACCESS_KEY"
        value = var.minio_credentials.username
      }

      env {
        name  = "MINIO_SECRET_KEY"
        value = var.minio_credentials.password
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 1206

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

