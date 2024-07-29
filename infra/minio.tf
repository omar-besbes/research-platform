locals {
  minio_storage_share_name = "minio-storage"
}

resource "azurerm_container_group" "minio" {
  name                = "efrei-minio-cg"
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
    name   = "minio"
    image  = "minio/minio:latest"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 9000
      protocol = "TCP"
    }
    ports {
      port     = 9001
      protocol = "TCP"
    }
    commands = [
      "server",
      "/data",
      "--console-address",
      ":9001"
    ]
    environment_variables = {
      MINIO_ROOT_USER     = "minioadmin"
      MINIO_ROOT_PASSWORD = "minioadmin"
    }
    volume {
      name                 = local.minio_storage_share_name
      mount_path           = "/data"
      share_name           = azurerm_storage_share.minio.name
      storage_account_name = azurerm_storage_account.efrei.name
      storage_account_key  = azurerm_storage_account.efrei.primary_access_key
    }
  }
}

resource "azurerm_storage_share" "minio" {
  name = local.minio_storage_share_name

  storage_account_name = azurerm_storage_account.efrei.name
  quota                = 20
}
