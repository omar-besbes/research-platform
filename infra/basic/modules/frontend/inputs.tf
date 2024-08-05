#######################
# Variables
#######################

variable "registry" {}

variable "resource_group_name" {}

variable "location" {}

variable "vnet_name" {}

variable "subnet_name" {}

variable "identity_name" {}

variable "domain_names" {}

variable "app_name" {}

#######################
# Data sources
#######################

data "azurerm_virtual_network" "efrei" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "efrei" {
  name                = var.subnet_name
  resource_group_name = var.resource_group_name

  virtual_network_name = data.azurerm_virtual_network.efrei.name
}

data "azurerm_user_assigned_identity" "efrei" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
}
