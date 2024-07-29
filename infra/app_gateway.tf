locals {
  gateway_ip_config_name     = "efrei-gw-ipcfg"
  frontend_port_name         = "efrei-port"
  frontend_ip_config_name    = "efrei-fe-ipcfg"
  backend_pool_name          = "efrei-be-pool"
  backend_http_settings_name = "efrei-bd-htst"
  http_listener_name         = "efrei-httplstn"
  request_routing_rule_name  = "efrei-rqrt"
}

resource "azurerm_application_gateway" "efrei" {
  name                = "efrei-app-gateway"
  location            = data.azurerm_resource_group.efrei.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_config_name
    subnet_id = azurerm_subnet.efrei.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.efrei.id
  }

  backend_address_pool {
    name = local.backend_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_config_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 9
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }
}
