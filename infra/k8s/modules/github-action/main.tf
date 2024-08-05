locals {
  audience = ["api://AzureADTokenExchange"]
  issuer   = "https://token.actions.githubusercontent.com"
  subject  = var.github_action_federated_credential_subject
}

# Give Github Action permissions to deploy to Azure
resource "azurerm_user_assigned_identity" "github_action" {
  name                = var.github_action_user_assigned_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "github_action" {
  name                = "github_action"
  resource_group_name = var.resource_group_name

  audience  = local.audience
  issuer    = local.issuer
  parent_id = azurerm_user_assigned_identity.github_action.id
  subject   = "repo:${local.subject.organization}/${local.subject.repository}:${local.subject.entity}:${local.subject.entity_value}"
}
