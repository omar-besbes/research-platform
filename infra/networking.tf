data "azurerm_resource_group" "efrei" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "efrei" {
  name                = "efrei-vnet"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "efrei" {
  name                = "efrei-subnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.efrei.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_public_ip" "efrei" {
  name                = "efrei-pip"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.efrei.location

  allocation_method = "Static"
  sku               = "Standard"
}
