variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "efrei-rg"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  default     = "efrei-k8s-cluster"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  default     = "efrei-cr"
}

variable "app_gateway_name" {
  description = "The name of the Application Gateway for Containers"
  default     = "efrei-alb"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  default     = "efrei-vnet"
}

variable "subnet_name" {
  description = "Then name of the subnet in the virtual network"
  default     = "efrei-subnet"
}
