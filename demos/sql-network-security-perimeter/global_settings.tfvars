global_settings = {
  default_region = "region1"
  regions        = { region1 = "spaincentral" }
  random_length  = 0
  passthrough    = true
  inherit_tags   = false
}

landingzone = {
  key          = "sql-nsp-demo"
  level        = "level0"
  backend_type = "local"
}

resource_provider_registrations = "none"
storage_use_azuread             = true
tags                            = { purpose = "Disposable SQL outbound NSP demo" }
