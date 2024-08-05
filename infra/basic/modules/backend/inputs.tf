#######################
# Variables
#######################

variable "registry" {}

variable "resource_group_name" {}

variable "location" {}

variable "identity_name" {}

variable "pg_server_name" {}

variable "pg_credentials" {}

variable "domain_names" {}

variable "app_name" {}

variable "env_name" {}

#######################
# Data sources
#######################

data "azurerm_container_app_environment" "efrei" {
  name                = var.env_name
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "efrei" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
}

data "azurerm_postgresql_flexible_server" "efrei" {
  name                = var.pg_server_name
  resource_group_name = var.resource_group_name
}
