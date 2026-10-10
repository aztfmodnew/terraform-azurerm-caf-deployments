resource "azurerm_mssql_server" "entra_only" {
  for_each = var.entra_only_sql_servers

  name                          = each.value.name
  resource_group_name           = module.example.resource_groups[each.value.resource_group_key].name
  location                      = var.global_settings.regions[each.value.region]
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  connection_policy             = "Proxy"
  public_network_access_enabled = true
  tags                          = local.tags

  azuread_administrator {
    login_username              = each.value.administrator.login_username
    object_id                   = each.value.administrator.object_id
    tenant_id                   = each.value.administrator.tenant_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_firewall_rule" "entra_only_operator" {
  for_each = var.entra_only_sql_servers

  name             = "operator-only"
  server_id        = azurerm_mssql_server.entra_only[each.key].id
  start_ip_address = each.value.operator_ipv4
  end_ip_address   = each.value.operator_ipv4
}

locals {
  # A separate landing-zone namespace avoids a cycle through CAF's own SQL output.
  caf_remote_objects = merge(var.remote_objects, {
    mssql_servers = merge(try(var.remote_objects.mssql_servers, {}), {
      entra_only = {
        for key, server in azurerm_mssql_server.entra_only : key => {
          id   = server.id
          name = server.name
        }
      }
    })
  })

  # Filtered object comprehensions preserve known keys without unifying A/C's
  # different access-rule object types in a conditional expression.
  demo_network_security_perimeters = {
    for key, perimeter in var.network_security_perimeters : key => merge(perimeter,
      {
        for demo in var.sql_nsp_demo[*] : "resource_associations" => {
          for association_key, association in perimeter.resource_associations : association_key => merge(association, {
            access_mode = demo.access_mode == "Transition" ? "Learning" : demo.access_mode
          })
        } if key == demo.nsp_key
      },
      {
        for demo in var.sql_nsp_demo[*] : "access_rules" => merge(perimeter.access_rules,
          {
            operator = {
              name             = "operator-inbound"
              profile_key      = demo.profile_key
              direction        = "Inbound"
              address_prefixes = ["${var.entra_only_sql_servers[demo.sql_server_key].operator_ipv4}/32"]
            }
          },
          {
            for enabled in [demo] : "blob" => {
              name                         = "blob-outbound"
              profile_key                  = enabled.profile_key
              direction                    = "Outbound"
              fully_qualified_domain_names = ["${var.storage_accounts[enabled.storage_account_key].name}.blob.core.windows.net"]
            } if enabled.allow_blob_outbound
          }
        ) if key == demo.nsp_key
      }
    )
  }
}

resource "azurerm_role_assignment" "sql_nsp_sas_operator" {
  count = var.sql_nsp_demo == null ? 0 : 1

  scope                = module.example.storage_accounts[var.sql_nsp_demo.storage_account_key].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.entra_only_sql_servers[var.sql_nsp_demo.sql_server_key].administrator.object_id
}

output "sql_nsp_demo" {
  description = "Non-secret endpoints for the SQL runner; all other CAF outputs remain under objects."
  precondition {
    condition     = var.sql_nsp_demo == null ? true : try(var.global_settings.passthrough, false) && try(var.global_settings.random_length, 4) == 0
    error_message = "SQL NSP's exact static FQDN requires global_settings.passthrough=true and random_length=0, as supplied by this demo."
  }

  value = var.sql_nsp_demo == null ? null : {
    sql_server_fqdn      = azurerm_mssql_server.entra_only[var.sql_nsp_demo.sql_server_key].fully_qualified_domain_name
    storage_account_name = nonsensitive(module.example.storage_accounts[var.sql_nsp_demo.storage_account_key].name)
    blob_host            = "${nonsensitive(module.example.storage_accounts[var.sql_nsp_demo.storage_account_key].name)}.blob.core.windows.net"
    access_mode          = var.sql_nsp_demo.access_mode
    api_access_mode      = var.sql_nsp_demo.access_mode == "Transition" ? "Learning" : var.sql_nsp_demo.access_mode
    allow_blob_outbound  = var.sql_nsp_demo.allow_blob_outbound
  }
}
