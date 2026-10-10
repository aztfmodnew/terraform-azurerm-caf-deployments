param(
    [Parameter(Mandatory)][string]$PlanFile,
    [Parameter(Mandatory)][ValidateSet('A','B','C','D')][string]$State
)
$ErrorActionPreference = 'Stop'
$planJson = terraform show -json $PlanFile
if ($LASTEXITCODE -ne 0) { throw 'Cannot read saved root plan.' }
$plan = $planJson | ConvertFrom-Json -Depth 100
function Assert($condition, $message) {
    if (-not $condition) { throw $message }
}
function Resource($type, $suffix) {
    $found = @($plan.resource_changes | Where-Object { $_.type -eq $type -and $_.address.EndsWith($suffix) })
    Assert ($found.Count -eq 1) "Expected exactly one $type $suffix."
    return $found[0]
}
Assert (@($plan.resource_changes | Where-Object { $_.change.actions -contains 'delete' }).Count -eq 0) 'Initial plan unexpectedly deletes resources.'
$server = Resource azurerm_mssql_server 'entra_only["lab"]'
Assert ($server.change.after.azuread_administrator[0].azuread_authentication_only -eq $true) 'SQL must be Entra-only.'
Assert ($null -eq $server.change.after.administrator_login_password) 'SQL password must not be supplied.'
Assert (@($server.change.after.identity).Count -eq 0) 'SQL managed identity invalidates the blockage demonstration.'
Assert ($server.change.after_unknown.id -eq $true) 'Initial SQL ID must be unknown.'
Assert (@($plan.resource_changes | Where-Object { $_.type -in @('random_password','azurerm_key_vault_secret','azurerm_key_vault') }).Count -eq 0) 'Unexpected password/Key Vault helper.'
$db = Resource azurerm_mssql_database 'mssqldb'
Assert ($db.change.after.sku_name -eq 'Basic' -and $db.change.after.storage_account_type -eq 'Local') 'Expected Basic with Local backups.'
$storage = Resource azurerm_storage_account 'stg'
Assert ($storage.change.after.shared_access_key_enabled -eq $false -and $storage.change.after.allow_nested_items_to_be_public -eq $false) 'Storage must disable shared keys and public blobs.'
$container = Resource azurerm_storage_container 'stg'
Assert ($container.change.after.container_access_type -eq 'private') 'Container must be private.'
$association = Resource azapi_resource 'resourceAssociations["sql"]'
$body = $association.change.after.body
if ($body -is [string]) { $body = $body | ConvertFrom-Json }
$mode = if ($State -eq 'A') { 'Learning' } else { 'Enforced' }
Assert ($body.properties.accessMode -eq $mode) 'Incorrect NSP API mode.'
Assert ($association.change.after_unknown.body.properties.privateLinkResource.id -eq $true) 'Association must accept unknown SQL ID in the initial root plan.'
Assert (@($plan.resource_changes | Where-Object { $_.address -like '*resourceAssociations*' }).Count -eq 1) 'Storage must remain outside NSP.'
$inbound = Resource azapi_resource 'accessRules["operator"]'
$inboundBody = $inbound.change.after.body
if ($inboundBody -is [string]) { $inboundBody = $inboundBody | ConvertFrom-Json }
Assert ($inboundBody.properties.addressPrefixes[0] -eq '203.0.113.10/32') 'Documentary inbound /32 must stay constant.'
$blob = @($plan.resource_changes | Where-Object { $_.address.EndsWith('accessRules["blob"]') })
$expected = if ($State -eq 'C') { 1 } else { 0 }
Assert ($blob.Count -eq $expected) 'Outbound FQDN rule does not match A/B/C/D.'
if ($State -eq 'C') {
    $blobBody = $blob[0].change.after.body
    if ($blobBody -is [string]) { $blobBody = $blobBody | ConvertFrom-Json }
    Assert ($blobBody.properties.fullyQualifiedDomainNames[0] -eq 'stnspdemochange123.blob.core.windows.net') 'Outbound rule must be exact account FQDN.'
}
$diagnostics = Resource azurerm_monitor_diagnostic_setting 'diagnostics["lab"]'
Assert (@($diagnostics.change.after.enabled_log).Count -gt 0) 'NSP diagnostics missing.'
Assert ($plan.configuration.root_module.module_calls.example.source -match '^(registry\.terraform\.io/)?aztfmodnew/caf/azurerm$') 'Wrong CAF root source.'
Write-Output "PASS: State $State real root plan: Entra-only, unknown SQL/association IDs, no Key Vault/password/identity, Basic Local, private Storage outside NSP, /32, mode/FQDN, diagnostics."
