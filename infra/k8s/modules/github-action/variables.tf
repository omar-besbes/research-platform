variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "github_action_user_assigned_identity_name" {
  description = "The name of the user assigned identity used for authenticating Github Action"
  default     = "github_action"
}

variable "github_action_federated_credential_name" {
  description = "The name of the federated credentials used for authenticating Github Action"
  default     = "github_action"
}

variable "github_action_federated_credential_subject" {
  description = "GitHub Action Federated Credential subject details"
  type = object({
    organization = string
    repository   = string
    entity       = string
    entity_value = string
  })
  default = {
    organization = "omar-besbes"
    repository   = "research-platform"
    entity       = "environment"
    entity_value = "preview"
  }
}
