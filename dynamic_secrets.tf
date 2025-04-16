module "dynamic_keyvault_secrets" {
  source  = "aztfmodnew/caf/azurerm//modules/security/dynamic_keyvault_secrets"
  version = "~>4.26.1"
  # source = "git::https://github.com/aztfmodnew/terraform-azurerm-caf.git//modules/security/dynamic_keyvault_secrets?ref=4.16.0"

  for_each = {
    for keyvault_key, secrets in try(var.dynamic_keyvault_secrets, {}) : keyvault_key => {
      for key, value in secrets : key => value
      if try(value.value, null) == null
    }
  }

  settings = each.value
  keyvault = module.example.keyvaults[each.key]
  objects  = module.example
}