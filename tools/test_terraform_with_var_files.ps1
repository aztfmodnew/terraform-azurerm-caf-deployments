$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'terraform_with_var_files.ps1')
$script:calls = [System.Collections.Generic.List[object]]::new()
$script:failAction = ''

function terraform {
    $calls.Add(@($args))
    $global:LASTEXITCODE = if ($args[0] -eq $failAction) { 1 } else { 0 }
    if ($args[0] -eq 'workspace' -and $args[1] -eq 'show') { return 'wrapper-test' }
}
function Assert($condition, $message) {
    if (-not $condition) { throw $message }
}

$fixtures = Join-Path $PSScriptRoot 'tests\var files'
Terraform-WithVarFiles -Dir $fixtures -Action plan -Workspace wrapper-test -TerraformArguments @('-input=false', '-out=plan with spaces.tfplan')
Assert ($script:calls.Count -eq 4) 'Expected init, explicit workspace, validate, plan.'
Assert (($script:calls[0] -join '|') -eq 'init|-input=false') 'Non-interactive init missing.'
Assert (($script:calls[1] -join '|') -eq 'workspace|select|-or-create|wrapper-test') 'Explicit workspace not preserved.'
$plan = $script:calls[3]
Assert ($plan.Count -eq 5) 'Arguments split or missing.'
Assert ($plan[1] -eq "-var-file=$(Join-Path $fixtures '01 global.tfvars')") 'First var-file is not one ordered argument.'
Assert ($plan[2] -eq "-var-file=$(Join-Path $fixtures '02 tags.tfvars')") 'Second var-file is not one ordered argument.'
Assert ($plan[4] -eq '-out=plan with spaces.tfplan') 'Extra argument split/evaluated.'

$script:calls.Clear()
Terraform-WithVarFiles -Dir $fixtures -Action import -Workspace wrapper-test -ResourceAddress 'module.example.resource["a b"]' -ResourceId '/an id with spaces'
$import = $script:calls[3]
Assert ($import[-2] -eq 'module.example.resource["a b"]' -and $import[-1] -eq '/an id with spaces') 'Import address/ID lost quoting.'

$script:failAction = 'plan'
$failed = $false
try { Terraform-WithVarFiles -Dir $fixtures -Action plan -Workspace wrapper-test } catch { $failed = $_.Exception.Message -like '*plan failed*' }
Assert $failed 'Plan failure did not propagate.'
foreach ($failure in @('init', 'workspace', 'validate')) {
    $script:calls.Clear()
    $script:failAction = $failure
    $failed = $false
    try { Terraform-WithVarFiles -Dir $fixtures -Action plan -Workspace wrapper-test } catch { $failed = $true }
    Assert $failed "$failure failure did not propagate."
    Assert (@($script:calls | Where-Object { $_[0] -eq 'plan' }).Count -eq 0) 'Plan ran after a prerequisite failed.'
}
$script:failAction = ''
$failed = $false
try {
    & (Join-Path $PSScriptRoot '..\demos\sql-network-security-perimeter\ejecutar-sql.ps1') -Action Read -Workspace incorrect-workspace
} catch {
    $failed = $_.Exception.Message -like '*workspace raiz actual*'
    if (-not $failed) { throw }
}
Assert $failed 'SQL runner did not reject workspace mismatch before requesting secrets.'
Write-Output 'PASS: PowerShell wrapper quoting/order/import/failure and SQL workspace guard (9 regressions).'
