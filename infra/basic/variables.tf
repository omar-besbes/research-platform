#######################
# Global
#######################

locals {
  backend_name       = "efrei-backend-ca"
  elasticsearch_name = "efrei-elasticsearch-ca"
  frontend_name      = "efrei-frontend-wa"
  go_wrapper_name    = "efrei-go-wrapper-ca"
  minio_name         = "efrei-minio-ca"
  postgres_name      = "efrei-db-pg"

  domain_names = {
    backend       = "${local.backend_name}.${var.container_app_environment_name}.azurecontainerapps.io"
    elasticsearch = "${local.elasticsearch_name}.${var.container_app_environment_name}.azurecontainerapps.io"
    frontend      = "${local.frontend_name}.azurewebsites.net"
    go_wrapper    = "${local.go_wrapper_name}.${var.container_app_environment_name}.azurecontainerapps.io"
    minio         = "${local.minio_name}.${var.container_app_environment_name}.azurecontainerapps.io"
    postgres      = "${module.postgres.hostname}"
  }
}

variable "registry" {
  description = "The registry in which reside container images"
}

variable "resource_group_name" {
  description = "Name of the resource groupe to be used"
  default     = "efrei-rg"
}

variable "container_app_environment_name" {
  description = "Name of the container app environment"
  default     = "efrei-env"
}

#######################
# Postgres
#######################

variable "pg_credentials" {
  sensitive = true
  type = object({
    username = string
    password = string
  })
  default = {
    username = "postgres"
    password = "secret"
  }
}

#######################
# Minio
#######################

variable "minio_credentials" {
  sensitive = true
  type = object({
    username = string
    password = string
  })
  default = {
    username = "minioadmin"
    password = "secret"
  }
}
