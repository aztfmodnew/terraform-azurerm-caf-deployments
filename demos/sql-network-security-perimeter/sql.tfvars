# Replace dummy IDs and globally unique names in an ignored zz-local.tfvars.
entra_only_sql_servers = {
  lab = {
    name               = "sql-nsp-demo-change-me"
    resource_group_key = "lab"
    region             = "region1"
    operator_ipv4      = "203.0.113.10"
    administrator = {
      login_username = "demo-operator"
      object_id      = "00000000-0000-0000-0000-000000000001"
      tenant_id      = "00000000-0000-0000-0000-000000000002"
    }
  }
}

mssql_databases = {
  demo = {
    name                 = "demo"
    resource_group_key   = "lab"
    region               = "region1"
    lz_key               = "entra_only"
    mssql_server_key     = "lab"
    sku_name             = "Basic"
    max_size_gb          = 2
    storage_account_type = "Local"
    zone_redundant       = false
  }
}
