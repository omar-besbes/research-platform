#######################
# Variables
#######################

variable "registry" {}

variable "resource_group_name" {}

variable "location" {}

variable "identity_name" {}

variable "domain_names" {}

variable "app_name" {}

variable "env_name" {}

variable "minio_credentials" {}

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
