sql_nsp_demo = {
  sql_server_key      = "lab"
  storage_account_key = "external"
  nsp_key             = "lab"
  profile_key         = "demo"
  access_mode         = "Transition"
  allow_blob_outbound = false
}

network_security_perimeters = {
  lab = {
    name               = "nsp-sql-demo"
    resource_group_key = "lab"
    location           = "spaincentral"
    profiles           = { demo = { name = "demo" } }
    # Root adds the permanent /32 from SQL settings and optional exact Blob FQDN.
    access_rules = {}
    resource_associations = {
      sql = {
        name        = "sql"
        profile_key = "demo"
        mssql_server = {
          lz_key = "entra_only"
          key    = "lab"
        }
        access_mode = "Learning"
      }
    }
    diagnostic_profiles = {
      lab = {
        definition_key   = "nsp"
        destination_type = "log_analytics"
        destination_key  = "lab"
      }
    }
  }
}
