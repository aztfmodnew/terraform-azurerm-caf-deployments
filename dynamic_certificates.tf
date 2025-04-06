module "dynamic_keyvault_certificates" {
  # source  = "aztfmod/caf/azurerm//modules/security/dynamic_keyvault_certificates"
  #source = "../modules/security/dynamic_keyvault_certificates"

  source   = "git::https://github.com/aztfmodnew/terraform-azurerm-caf.git//modules/security/dynamic_keyvault_certificates?ref=4.16.0"
  for_each = try(var.dynamic_keyvault_certificates, {})

  settings = each.value
  keyvault = module.example.keyvaults[each.key]
  objects  = module.example
}
