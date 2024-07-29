locals {
  elasticsearch_storage_share_name = "elasticsearch-storage"
}

resource "azurerm_container_group" "elasticsearch" {
  name                = "efrei-elasticsearch-cg"
  location            = data.azurerm_resource_group.efrei.location
  resource_group_name = var.resource_group_name

  ip_address_type = "Private"
  os_type         = "Linux"
  subnet_ids      = [azurerm_subnet.efrei.id]
  sku             = "Standard"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.efrei.id]
  }

  container {
    name   = "elasticsearch"
    image  = "docker.elastic.co/elasticsearch/elasticsearch:8.13.0"
    cpu    = "0.5"
    memory = "2"
    ports {
      port     = 9200
      protocol = "TCP"
    }
    ports {
      port     = 9300
      protocol = "TCP"
    }
    environment_variables = {
      xpack_security_enabled = "false"
      discovery_type         = "single-node"
      ES_JAVA_OPTS           = "-Xms512m -Xmx512m"
    }
    volume {
      name                 = local.elasticsearch_storage_share_name
      mount_path           = "/data"
      share_name           = azurerm_storage_share.elasticsearch.name
      storage_account_name = azurerm_storage_account.efrei.name
      storage_account_key  = azurerm_storage_account.efrei.primary_access_key
    }
  }
}

resource "azurerm_storage_share" "elasticsearch" {
  name = local.elasticsearch_storage_share_name

  storage_account_name = azurerm_storage_account.efrei.name
  quota                = 10
}
