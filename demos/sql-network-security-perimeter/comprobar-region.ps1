param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [Parameter(Mandatory)][string]$Location
)

$ErrorActionPreference = 'Stop'
$url = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Sql/locations/$Location/capabilities?api-version=2023-08-01"
$json = az rest --method get --url $url -o json --only-show-errors
if ($LASTEXITCODE -ne 0) { throw 'No se pudieron consultar las capacidades SQL de la suscripcion.' }
$capabilities = $json | ConvertFrom-Json
$sql12 = @($capabilities.supportedServerVersions | Where-Object { $_.name -eq '12.0' })
if ($sql12.Count -ne 1 -or $sql12[0].status -notin @('Available', 'Default')) {
    throw "SQL no permite aprovisionar en ${Location}: $($capabilities.reason)"
}
[pscustomobject]@{ Location = $Location; SQL = $sql12[0].status; Capability = 'Provisioning enabled' }
