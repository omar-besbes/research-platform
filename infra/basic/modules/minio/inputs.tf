#######################
# Variables
#######################

variable "registry" {}

variable "resource_group_name" {}

variable "location" {}

variable "storage_account_name" {}

variable "identity_name" {}

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

data "azurerm_storage_account" "efrei" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}
