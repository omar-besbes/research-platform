terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113.0"
    }
  }

  required_version = ">= 1.9.3"
}

provider "azurerm" {
  features {}
}

# Terraform State Backend
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "your-resource-group"
#     storage_account_name = "yourstorageaccount"
#     container_name       = "terraform"
#     key                  = "terraform.tfstate"
#   }
# }
