variable "provider_azurerm_features_api_management" {
  type = map(any)
  default = {
    purge_soft_delete_on_destroy         = true
    recover_soft_deleted_api_managements = true
  }
}

variable "provider_azurerm_features_application_insights" {
  type = map(any)
  default = {
    disable_generated_rule = false
  }
}

variable "provider_azurerm_features_cognitive_account" {
  type = map(any)
  default = {
    purge_soft_delete_on_destroy = true
  }
}

variable "provider_azurerm_features_keyvault" {
  type = map(any)
  default = {
    purge_soft_delete_on_destroy               = true # for CI....
    purge_soft_deleted_certificates_on_destroy = false
    purge_soft_deleted_keys_on_destroy         = false
    purge_soft_deleted_secrets_on_destroy      = false
    recover_soft_deleted_certificates          = true
    recover_soft_deleted_key_vaults            = true
    recover_soft_deleted_keys                  = true
    recover_soft_deleted_secrets               = true
  }
}

variable "provider_azurerm_features_log_analytics_workspace" {
  type = map(any)
  default = {
    permanently_delete_on_destroy = true
  }
}

variable "provider_azurerm_features_resource_group" {
  type = map(any)
  default = {
    prevent_deletion_if_contains_resources = false
  }
}

variable "provider_azurerm_features_template_deployment" {
  type = map(any)
  default = {
    delete_nested_items_during_deletion = false
  }
}

variable "provider_azurerm_features_virtual_machine" {
  type = map(any)
  default = {
    delete_os_disk_on_deletion     = true
    graceful_shutdown              = false
    skip_shutdown_and_force_delete = true # for CI.....
  }
}

variable "provider_azurerm_features_virtual_machine_scale_set" {
  type = map(any)
  default = {
    force_delete                  = true # for CI ....
    roll_instances_when_required  = true
    scale_to_zero_before_deletion = true
  }
}