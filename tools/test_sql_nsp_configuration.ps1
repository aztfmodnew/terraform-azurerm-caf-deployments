$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Push-Location $repo
try {
    $varFiles = @(Get-ChildItem 'demos\sql-network-security-perimeter' -Filter '*.tfvars' -File | Sort-Object Name | ForEach-Object { "-var-file=$($_.FullName)" })
    foreach ($state in @('A', 'B', 'C', 'D')) {
        $mode = if ($state -eq 'A') { 'Transition' } else { 'Enforced' }
        $apiMode = if ($state -eq 'A') { 'Learning' } else { 'Enforced' }
        $allow = if ($state -eq 'C') { 'true' } else { 'false' }
        $setting = '-var=sql_nsp_demo={sql_server_key="lab",storage_account_key="external",nsp_key="lab",profile_key="demo",access_mode="' + $mode + '",allow_blob_outbound=' + $allow + '}'
        $expression = 'local.demo_network_security_perimeters["lab"].resource_associations["sql"].access_mode == "' + $apiMode + '" && contains(keys(local.demo_network_security_perimeters["lab"].access_rules), "blob") == ' + $allow + ' && local.demo_network_security_perimeters["lab"].access_rules["operator"].address_prefixes == ["203.0.113.10/32"]'
        $result = $expression | terraform console @varFiles $setting
        if ($LASTEXITCODE -ne 0 -or ($result -join '').Trim() -ne 'true') { throw "Configuration state $state failed." }
        Write-Output "PASS: $state mode, optional outbound key and constant /32."
    }
    $result = 'length(var.entra_only_sql_servers) == 0 && var.sql_nsp_demo == null && local.demo_network_security_perimeters == {}' | terraform console
    if ($LASTEXITCODE -ne 0 -or ($result -join '').Trim() -ne 'true') { throw 'Empty/default helper gates failed.' }
    Write-Output 'PASS: Other demos leave SQL helper and NSP overrides disabled.'
} finally {
    Pop-Location
}
