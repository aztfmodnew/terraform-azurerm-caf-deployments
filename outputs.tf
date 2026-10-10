
output "objects" {
  value = tomap(
    { (var.landingzone.key) = {
      for key, value in module.example : key => value
      if try(value, {}) != {}
      }
    }
  )
  sensitive = true

  precondition {
    condition = alltrue([
      for settings in [
        var.batch_certificates, var.postgresql_servers,
        var.front_doors, var.front_door_waf_policies,
        var.cdn_profile, var.cdn_endpoint,
        var.app_service_plans, var.app_services, var.function_apps, var.sentinel
      ] : length(settings) == 0
    ])
    error_message = "CAF 5 removed legacy Batch certificates, PostgreSQL Single Server, Front Door/CDN Classic, generic App Service/Function and security.sentinel inputs. Migrate these non-empty inputs (see tools/CAF5.md); they must not be silently ignored."
  }
}