locals {
  storage_share_name = "elasticsearch-storage"
}

resource "azurerm_storage_share" "elasticsearch" {
  name = local.storage_share_name

  storage_account_name = data.azurerm_storage_account.efrei.name
  quota                = 10
}

resource "azurerm_container_app_environment_storage" "elasticsearch" {
  name = "efrei-elasticsearch-envstrg"

  container_app_environment_id = data.azurerm_container_app_environment.efrei.id
  account_name                 = data.azurerm_storage_account.efrei.name
  access_key                   = data.azurerm_storage_account.efrei.primary_access_key
  share_name                   = local.storage_share_name
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app" "elasticsearch" {
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
      name   = "elasticsearch"
      image  = "docker.elastic.co/elasticsearch/elasticsearch:8.13.0"
      cpu    = "1"
      memory = "2Gi"

      env {
        name  = "xpack_security_enabled"
        value = "false"
      }

      env {
        name  = "discovery_type"
        value = "single-node"
      }

      env {
        name  = "ES_JAVA_OPTS"
        value = "-Xms512m -Xmx512m"
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
    target_port      = 9200

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
