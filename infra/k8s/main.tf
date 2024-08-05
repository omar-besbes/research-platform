data "azurerm_resource_group" "efrei" {
  name = var.resource_group_name
}

module "container_registry" {
  source = "./modules/container-registry"

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  acr_name            = var.acr_name
  principal_id        = module.k8s_cluster.principal_id
}

module "k8s_cluster" {
  source = "./modules/aks"

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
  aks_cluster_name    = var.aks_cluster_name
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
}

module "github_action" {
  source = "./modules/github-action"

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location
}
