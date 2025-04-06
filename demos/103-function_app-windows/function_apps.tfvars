function_apps = {
  faaps1_region1 = {
    name                 = "func-app-sbx-ne-001"
    resource_group_key   = "rg_app_region1"
    region               = "region1"
    app_service_plan_key = "plan-app-sbx-ne-001"
    storage_account_key  = "sa_app_region1"
    settings = {
      version = "~3"
    }
  }
}