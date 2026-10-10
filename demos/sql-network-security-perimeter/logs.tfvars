diagnostic_log_analytics = {
  lab = {
    name               = "law-sql-nsp-demo"
    resource_group_key = "lab"
    region             = "region1"
    sku                = "PerGB2018"
    retention_in_days  = 30
    daily_quota_gb     = 1
  }
}

diagnostics_destinations = {
  log_analytics = {
    lab = { log_analytics_key = "lab" }
  }
}

diagnostics_definition = {
  nsp = {
    name = "nsp-to-workspace"
    categories = {
      log = [
        ["NspOutboundAttempt", true, false, 0],
        ["NspPublicInboundPerimeterRulesAllowed", true, false, 0],
        ["NspPublicInboundPerimeterRulesDenied", true, false, 0],
        ["NspPublicInboundResourceRulesAllowed", true, false, 0],
        ["NspPublicInboundResourceRulesDenied", true, false, 0],
        ["NspPublicOutboundPerimeterRulesAllowed", true, false, 0],
        ["NspPublicOutboundPerimeterRulesDenied", true, false, 0],
        ["NspPublicOutboundResourceRulesAllowed", true, false, 0],
        ["NspPublicOutboundResourceRulesDenied", true, false, 0],
      ]
    }
  }
}
