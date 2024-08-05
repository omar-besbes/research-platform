data "azurerm_resource_group" "efrei" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "efrei" {
  name                = "efreistorageaccount"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_container_app_environment" "efrei" {
  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  infrastructure_subnet_id = azurerm_subnet.container_app_env.id
}

module "backend" {
  source = "./modules/backend"

  registry            = var.registry
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  identity_name       = azurerm_user_assigned_identity.efrei.name
  app_name            = local.backend_name
  env_name            = var.container_app_environment_name
  domain_names        = local.domain_names
  pg_credentials      = var.pg_credentials
  pg_server_name      = local.postgres_name

  depends_on = [azurerm_container_app_environment.efrei, azurerm_user_assigned_identity.efrei, module.postgres]
}

module "elasticsearch" {
  source = "./modules/elasticsearch"

  registry             = var.registry
  resource_group_name  = var.resource_group_name
  location             = data.azurerm_resource_group.efrei.location
  identity_name        = azurerm_user_assigned_identity.efrei.name
  storage_account_name = azurerm_storage_account.efrei.name
  app_name             = local.elasticsearch_name
  env_name             = var.container_app_environment_name

  depends_on = [azurerm_container_app_environment.efrei, azurerm_user_assigned_identity.efrei]
}

module "frontend" {
  source = "./modules/frontend"

  registry            = var.registry
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  vnet_name           = azurerm_virtual_network.efrei.name
  subnet_name         = azurerm_subnet.service_app_env.name
  identity_name       = azurerm_user_assigned_identity.efrei.name
  app_name            = local.frontend_name
  domain_names        = local.domain_names

  depends_on = [azurerm_container_app_environment.efrei, azurerm_user_assigned_identity.efrei]
}

module "go_wrapper" {
  source = "./modules/go-wrapper"

  registry            = var.registry
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  identity_name       = azurerm_user_assigned_identity.efrei.name
  app_name            = local.go_wrapper_name
  env_name            = var.container_app_environment_name
  domain_names        = local.domain_names
  minio_credentials   = var.minio_credentials

  depends_on = [azurerm_container_app_environment.efrei, azurerm_user_assigned_identity.efrei]
}

module "minio" {
  source = "./modules/minio"

  registry             = var.registry
  resource_group_name  = var.resource_group_name
  location             = data.azurerm_resource_group.efrei.location
  identity_name        = azurerm_user_assigned_identity.efrei.name
  storage_account_name = azurerm_storage_account.efrei.name
  app_name             = local.minio_name
  env_name             = var.container_app_environment_name
  minio_credentials    = var.minio_credentials

  depends_on = [azurerm_container_app_environment.efrei, azurerm_user_assigned_identity.efrei]
}

module "postgres" {
  source = "./modules/postgres"

  registry            = var.registry
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  vnet_name           = azurerm_virtual_network.efrei.name
  subnet_name         = azurerm_subnet.storage.name
  pg_credentials      = var.pg_credentials
  db_name             = local.postgres_name

  depends_on = [azurerm_subnet.storage, azurerm_user_assigned_identity.efrei]
}
