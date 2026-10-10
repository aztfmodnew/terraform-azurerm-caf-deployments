param(
    [Parameter(Mandatory)]
    [ValidateSet('Prepare', 'Read', 'Cleanup')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    $server = terraform output -raw sql_server_fqdn
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener SQL del state.' }
    $blobHost = terraform output -raw blob_host
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener Blob del state.' }
    $token = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv --only-show-errors
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw 'No se pudo obtener el token Entra para SQL.'
    }
    $sas = $null
    if ($Action -eq 'Prepare') {
        $account = terraform output -raw storage_account_name
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo obtener Storage del state.' }
        $start = (Get-Date).ToUniversalTime().AddMinutes(-5).ToString('yyyy-MM-ddTHH:mm:ssZ')
        $expiry = (Get-Date).ToUniversalTime().AddHours(2).ToString('yyyy-MM-ddTHH:mm:ssZ')
        $sas = az storage container generate-sas --account-name $account --name events --permissions rwdl --start $start --expiry $expiry --https-only --auth-mode login --as-user -o tsv --only-show-errors
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($sas)) {
            throw 'No se pudo emitir la SAS de delegacion.'
        }
    }
    $files = @{ Prepare = '01-preparar.sql'; Read = '02-leer.sql'; Cleanup = '03-limpiar.sql' }
    $sql = Get-Content -LiteralPath (Join-Path $PSScriptRoot $files[$Action]) -Raw
    $sql = $sql.Replace(':On Error exit', '').Replace('$(BlobHost)', $blobHost)
    if ($Action -eq 'Prepare') { $sql = $sql.Replace('$(ContainerSas)', $sas.Replace("'", "''")) }
    $connection = [System.Data.SqlClient.SqlConnection]::new(
        "Server=tcp:$server,1433;Database=demo;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    )
    $connection.AccessToken = $token
    try {
        $connection.Open()
        $rows = 0
        foreach ($batch in [regex]::Split($sql, '(?im)^\s*GO\s*$')) {
            if ([string]::IsNullOrWhiteSpace($batch)) { continue }
            $command = $connection.CreateCommand()
            $command.CommandTimeout = 60
            $command.CommandText = $batch
            try {
                $reader = $command.ExecuteReader()
                try {
                    do {
                        while ($reader.Read()) {
                            if ($Action -eq 'Read' -and $reader.FieldCount -eq 2 -and $reader.GetName(0) -eq 'object_name') {
                                $rows++
                            }
                        }
                    } while ($reader.NextResult())
                } finally { $reader.Dispose() }
            } finally { $command.Dispose() }
        }
        [pscustomobject]@{
            Action = $Action
            UTC = (Get-Date).ToUniversalTime().ToString('o')
            EventRows = $rows
            Result = if ($Action -eq 'Read' -and $rows -eq 0) { 'Empty: not conclusive' } else { 'Completed' }
        } | ConvertTo-Json -Compress
        if ($Action -eq 'Read' -and $rows -eq 0) { exit 2 }
    } catch [System.Data.SqlClient.SqlException] {
        [pscustomobject]@{
            Action = $Action
            UTC = (Get-Date).ToUniversalTime().ToString('o')
            ErrorNumber = $_.Exception.Number
            Message = $_.Exception.Message
        } | ConvertTo-Json -Compress | Write-Error
        exit 1
    } finally {
        $connection.Dispose()
        $token = $null
        $sas = $null
        $sql = $null
    }
} finally { Pop-Location }
