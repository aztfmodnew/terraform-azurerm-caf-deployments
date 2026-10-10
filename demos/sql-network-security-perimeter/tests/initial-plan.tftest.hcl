mock_provider "azurerm" {
  override_during = plan
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "11111111-1111-1111-1111-111111111111"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
      object_id       = "22222222-2222-2222-2222-222222222222"
      client_id       = "33333333-3333-3333-3333-333333333333"
    }
  }
  mock_data "azurerm_subscription" {
    defaults = {
      subscription_id = "11111111-1111-1111-1111-111111111111"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
    }
  }
  mock_resource "azurerm_mssql_server" {
    override_during = apply
  }
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.Storage/storageAccounts/stnsptest123"
    }
  }
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql"
    }
  }
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.OperationalInsights/workspaces/law-test"
    }
  }
  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql"
      name     = "rg-nsp-tour-sql"
      location = "westeurope"
      tags     = {}
    }
  }
}
mock_provider "azapi" {}
mock_provider "azurecaf" {}
mock_provider "azuread" {
  mock_data "azuread_client_config" {
    defaults = {
      tenant_id = "11111111-1111-1111-1111-111111111111"
      object_id = "22222222-2222-2222-2222-222222222222"
      client_id = "33333333-3333-3333-3333-333333333333"
    }
  }
}
mock_provider "random" {}
mock_provider "null" {}
mock_provider "time" {}

variables {
  subscription_id     = "11111111-1111-1111-1111-111111111111"
  unique_suffix       = "test123"
  operator_ipv4       = "203.0.113.10"
  sql_admin_name      = "Lab administrator"
  sql_admin_object_id = "22222222-2222-2222-2222-222222222222"
}

run "initial_sql_id_unknown" {
  command = plan
  assert {
    condition     = output.demo_state.access_mode == "Transition"
    error_message = "A fresh plan must work before the SQL resource ID is known."
  }
}
