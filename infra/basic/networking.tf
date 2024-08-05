resource "azurerm_virtual_network" "efrei" {
  name                = "efrei-vnet"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "storage" {
  name                = "efrei-storage-subnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.efrei.name
  address_prefixes     = ["10.0.0.0/20"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "containers" {
  name                = "efrei-containers-subnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.efrei.name
  address_prefixes     = ["10.0.16.0/20"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "container_app_env" {
  name                = "efrei-container-app-env-subnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.efrei.name
  address_prefixes     = ["10.0.32.0/20"]
}

resource "azurerm_subnet" "service_app_env" {
  name                = "efrei-service-app-env-subnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.efrei.name
  address_prefixes     = ["10.0.48.0/20"]

  delegation {
    name = "sae-delegation"
    service_delegation {
      name = "Microsoft.Web/hostingEnvironments"
    }
  }
}
