terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.11.0"
    }
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

provider "azapi" {
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "operator" {}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.lab_name}"
  location = var.location
  tags     = { purpose = "Azure Tour disposable NSP SQL lab" }
}

resource "azurerm_mssql_server" "lab" {
  name                          = "${var.lab_name}-${var.unique_suffix}"
  resource_group_name           = azurerm_resource_group.lab.name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  connection_policy             = "Proxy"
  public_network_access_enabled = true
  azuread_administrator {
    login_username              = var.sql_admin_name
    object_id                   = var.sql_admin_object_id
    tenant_id                   = data.azurerm_client_config.operator.tenant_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "lab" {
  name           = "demo"
  server_id      = azurerm_mssql_server.lab.id
  sku_name       = "Basic"
  max_size_gb    = 2
  zone_redundant = false
}

resource "azurerm_mssql_firewall_rule" "operator" {
  name             = "operator-only"
  server_id        = azurerm_mssql_server.lab.id
  start_ip_address = var.operator_ipv4
  end_ip_address   = var.operator_ipv4
}

resource "azurerm_storage_account" "external" {
  name                            = "stnsp${var.unique_suffix}"
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  public_network_access           = "Enabled"
}

resource "azurerm_storage_container" "events" {
  name                  = "events"
  storage_account_id    = azurerm_storage_account.external.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "sas_operator" {
  scope                = azurerm_storage_account.external.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.operator.object_id
}

resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-${var.lab_name}-${var.unique_suffix}"
  resource_group_name = azurerm_resource_group.lab.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
}

module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "5.0.0"

  current_landingzone_key = "sql-nsp-demo"
  global_settings = {
    default_region = "region1"
    regions        = { region1 = var.location }
    random_length  = 0
    passthrough    = true
    inherit_tags   = false
  }
  resource_groups = {
    lab = { name = azurerm_resource_group.lab.name, reuse = true }
  }
  remote_objects = {
    mssql_servers = {
      external = { lab = { id = azurerm_mssql_server.lab.id } }
    }
  }
  networking = {
    network_security_perimeters = {
      lab = {
        resource_group_key = "lab"
        name               = "nsp-${var.lab_name}"
        location           = var.location
        profiles           = { demo = { name = "demo" } }
        resource_associations = {
          sql = {
            name         = "sql"
            profile_key  = "demo"
            mssql_server = { lz_key = "external", key = "lab" }
            access_mode  = var.access_mode
          }
        }
        access_rules = merge(
          {
            operator = {
              name             = "operator-inbound"
              profile_key      = "demo"
              direction        = "Inbound"
              address_prefixes = ["${var.operator_ipv4}/32"]
            }
          },
          var.allow_blob_outbound ? {
            blob = {
              name                         = "blob-outbound"
              profile_key                  = "demo"
              direction                    = "Outbound"
              fully_qualified_domain_names = ["${azurerm_storage_account.external.name}.blob.core.windows.net"]
            }
          } : {}
        )
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsp" {
  name                       = "nsp-to-workspace"
  target_resource_id         = module.caf.network_security_perimeters["lab"].network_security_perimeter_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id
  enabled_log {
    category_group = "allLogs"
  }
}
