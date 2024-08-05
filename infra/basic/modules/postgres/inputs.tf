#######################
# Variables
#######################

variable "registry" {}

variable "resource_group_name" {}

variable "location" {}

variable "vnet_name" {}

variable "subnet_name" {}

variable "pg_credentials" {}

variable "db_name" {}

variable "pg_version" {
  description = "Version of the postgres database"
  default     = "16"
}

variable "pg_storage_size" {
  description = "Size in MB of the storage size of the database"
  default     = 32768
}

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
