resource "azurerm_kubernetes_cluster" "efrei" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = "efrei"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.efrei.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  # Enable Workload Identity and OIDC issuer (necessary for setting up app gateway)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}

resource "azurerm_virtual_network" "efrei" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location

  address_space = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "efrei" {
  name                = var.subnet_name
  resource_group_name = var.resource_group_name

  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.1.0.0/22"]
}
