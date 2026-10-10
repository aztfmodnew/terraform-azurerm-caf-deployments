output "sql_server_fqdn" {
  value = azurerm_mssql_server.lab.fully_qualified_domain_name
}

output "database_name" {
  value = azurerm_mssql_database.lab.name
}

output "storage_account_name" {
  value = azurerm_storage_account.external.name
}

output "blob_host" {
  value = "${azurerm_storage_account.external.name}.blob.core.windows.net"
}

output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "nsp_id" {
  value = module.caf.network_security_perimeters["lab"].network_security_perimeter_id
}

output "demo_state" {
  value = { access_mode = var.access_mode, allow_blob_outbound = var.allow_blob_outbound }
}
