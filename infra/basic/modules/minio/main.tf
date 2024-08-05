locals {
  storage_share_name = "minio-storage"
}

resource "azurerm_storage_share" "minio" {
  name = local.storage_share_name

  storage_account_name = data.azurerm_storage_account.efrei.name
  quota                = 20
}

resource "azurerm_container_app_environment_storage" "minio" {
  name = "efrei-minio-envstrg"

  container_app_environment_id = data.azurerm_container_app_environment.efrei.id
  account_name                 = data.azurerm_storage_account.efrei.name
  access_key                   = data.azurerm_storage_account.efrei.primary_access_key
  share_name                   = local.storage_share_name
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app" "minio" {
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
      name   = "minio"
      image  = "minio/minio:latest"
      cpu    = "0.75"
      memory = "1.5Gi"

      args = [
        "server",
        "/data",
        "--console-address",
        ":9001"
      ]

      env {
        name  = "MINIO_ROOT_USER"
        value = var.minio_credentials.username
      }

      env {
        name  = "MINIO_ROOT_PASSWORD"
        value = var.minio_credentials.password
      }

      volume_mounts {
        name = local.storage_share_name
        path = "/data"
      }
    }

    volume {
      name = local.storage_share_name
    }
  }

  ingress {
    external_enabled = false
    target_port      = 9000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

