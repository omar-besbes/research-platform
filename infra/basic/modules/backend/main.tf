resource "azurerm_container_app" "backend" {
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
      name   = "backend"
      image  = "${var.registry}/backend:latest"
      cpu    = "0.75"
      memory = "1.5Gi"

      env {
        name  = "NODE_ENV"
        value = "development"
      }

      env {
        name  = "DB_URI"
        value = "postgres://${var.pg_credentials.username}:${var.pg_credentials.password}@${data.azurerm_postgresql_flexible_server.efrei.fqdn}:5432/db"
      }

      env {
        name  = "ELASTICSEARCH_NODE"
        value = "http://${var.domain_names.elasticsearch}:9200"
      }

      env {
        name  = "FRONTEND_URL"
        value = "http://${var.domain_names.frontend}:3000"
      }

      env {
        name  = "MINIO_WRAPPER_WS_URL"
        value = "ws://${var.domain_names.go_wrapper}:1206"
      }

      env {
        name  = "MINIO_WRAPPER_HTTP_URL"
        value = "http://${var.domain_names.go_wrapper}:1206"
      }
    }

  }

  ingress {
    external_enabled = true
    target_port      = 3011

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
