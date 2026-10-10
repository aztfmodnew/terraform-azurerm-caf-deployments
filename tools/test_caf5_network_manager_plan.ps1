param([Parameter(Mandatory)][string]$PlanFile)
$ErrorActionPreference = 'Stop'
$json = terraform show -json $PlanFile
if ($LASTEXITCODE -ne 0) { throw 'Cannot read saved network-manager plan.' }
$plan = $json | ConvertFrom-Json -Depth 100
$types = @($plan.resource_changes | ForEach-Object { $_.type })
if ('azurerm_network_manager' -notin $types) { throw 'Existing 300 demo did not plan a Network Manager.' }
if ('azurerm_mssql_server' -in $types -or 'azurerm_mssql_database' -in $types) { throw 'SQL demo leaked into the existing demo.' }
if (@($plan.resource_changes | Where-Object { $_.address -like '*sql_nsp_sas_operator*' -or $_.address -like '*network_security_perimeters*' }).Count -ne 0) {
    throw 'NSP/SQL demo resources must remain disabled for other demos.'
}
$manifest = Get-Content '.terraform\modules\modules.json' -Raw | ConvertFrom-Json
foreach ($key in @('example', 'dynamic_keyvault_certificates', 'dynamic_keyvault_secrets')) {
    $module = $manifest.Modules | Where-Object { $_.Key -eq $key }
    if ($module.Version -ne '5.0.0') { throw "$key is not installed at exact CAF 5.0.0." }
}
Write-Output 'PASS: Original 300 Network Manager demo plans with exact CAF 5.0.0; SQL/NSP helper resources absent.'
