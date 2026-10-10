module "dynamic_keyvault_certificates" {
  # source  = "aztfmod/caf/azurerm//modules/security/dynamic_keyvault_certificates"
  #source = "../modules/security/dynamic_keyvault_certificates"

  source   = "aztfmodnew/caf/azurerm//modules/security/dynamic_keyvault_certificates"
  version  = "5.0.0"
  for_each = try(var.dynamic_keyvault_certificates, {})

  settings = each.value
  keyvault = module.example.keyvaults[each.key]
  objects  = module.example
}
