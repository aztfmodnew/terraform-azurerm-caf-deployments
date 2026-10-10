mock_provider "azurerm" {
  override_during = plan
  mock_data "azurerm_subscription" {
    defaults = {
      subscription_id = "11111111-1111-1111-1111-111111111111"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
    }
  }
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "11111111-1111-1111-1111-111111111111"
      client_id       = "33333333-3333-3333-3333-333333333333"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
      object_id       = "22222222-2222-2222-2222-222222222222"
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
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql"
    }
  }
  mock_resource "azurerm_mssql_server" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.Sql/servers/nsp-tour-sql-test123"
    }
  }
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.Storage/storageAccounts/stnsptest123"
    }
  }
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.OperationalInsights/workspaces/law-test"
    }
  }
}

mock_provider "azapi" {
  override_during = plan
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-nsp-tour-sql/providers/Microsoft.Network/networkSecurityPerimeters/nsp-nsp-tour-sql"
    }
  }
}
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

run "a_transition" {
  command = plan
  assert {
    condition     = output.demo_state.access_mode == "Transition" && !output.demo_state.allow_blob_outbound
    error_message = "A must start in Transition without the outbound exception."
  }
  assert {
    condition     = azurerm_mssql_firewall_rule.operator.start_ip_address == var.operator_ipv4 && azurerm_mssql_firewall_rule.operator.end_ip_address == var.operator_ipv4
    error_message = "SQL client access must remain restricted to the operator."
  }
  assert {
    condition     = one(azurerm_mssql_server.lab.azuread_administrator).azuread_authentication_only && azurerm_storage_container.events.container_access_type == "private" && !azurerm_storage_account.external.shared_access_key_enabled
    error_message = "Require Entra-only SQL, private blobs and no shared account keys."
  }
}

run "b_enforced" {
  command = plan
  variables {
    access_mode = "Enforced"
  }
  assert {
    condition     = output.demo_state.access_mode == "Enforced" && !output.demo_state.allow_blob_outbound
    error_message = "B must enforce without the outbound exception."
  }
}

run "c_exact_fqdn" {
  command = plan
  variables {
    access_mode         = "Enforced"
    allow_blob_outbound = true
  }
  assert {
    condition     = output.demo_state.access_mode == "Enforced" && output.demo_state.allow_blob_outbound && output.blob_host == "stnsptest123.blob.core.windows.net"
    error_message = "C must enforce and permit only this lab's Blob FQDN."
  }
}

run "d_remove_rule" {
  command = plan
  variables {
    access_mode         = "Enforced"
    allow_blob_outbound = false
  }
  assert {
    condition     = output.demo_state.access_mode == "Enforced" && !output.demo_state.allow_blob_outbound
    error_message = "D must remove the exception without leaving Enforced."
  }
}

run "reject_learning_alias" {
  command = plan
  variables {
    access_mode = "Learning"
  }
  expect_failures = [var.access_mode]
}

run "reject_wide_ip" {
  command = plan
  variables {
    operator_ipv4 = "0.0.0.0"
  }
  expect_failures = [var.operator_ipv4]
}
