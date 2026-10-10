storage_accounts = {
  external = {
    name                            = "stnspdemochange123"
    resource_group_key              = "lab"
    region                          = "region1"
    account_kind                    = "StorageV2"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    access_tier                     = "Hot"
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = false
    allow_nested_items_to_be_public = false
    public_network_access_enabled   = true
    default_to_oauth_authentication = true
    containers = {
      events = {
        name                  = "events"
        container_access_type = "private"
      }
    }
  }
}
