app_service_plans = {
  asp1_region1 = {
    name               = "plan-app-sbx-ne-001"
    resource_group_key = "rg_app_region1"
    region             = "region1"
    kind               = "functionapp"

    sku = {
      tier = "Dynamic"
      size = "Y1"
    }
  }
}