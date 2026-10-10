function Terraform-WithVarFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Dir,

        [Parameter(Mandatory=$false)]
        [string]$Action,

        [Parameter(Mandatory=$false)]
        [string]$Auto,

        [Parameter(Mandatory=$false)]
        [string]$ResourceAddress,

        [Parameter(Mandatory=$false)]
        [string]$ResourceId,

        [Parameter(Mandatory=$false)]
        [string]$Workspace = "default",

        [string[]]$TerraformArguments = @(),

        [switch]$Help
    )

    if ($Help) {
        Write-Output "Usage: Terraform-WithVarFiles [OPTIONS]"
        Write-Output "Options:"
        Write-Output "  -Dir DIR                Specify the directory containing .tfvars files"
        Write-Output "  -Action ACTION          Specify the Terraform action (plan, apply, destroy, import)"
        Write-Output "  -Auto AUTO              Specify 'auto' for auto-approve (optional)"
        Write-Output "  -ResourceAddress ADDR   Specify the resource address for import action (optional)"
        Write-Output "  -ResourceId ID          Specify the resource ID for import action (optional)"
        Write-Output "  -Workspace WORKSPACE    Specify the Terraform workspace (default: default)"
        Write-Output "  -TerraformArguments ARGS Additional Terraform arguments (passed without evaluation)"
        Write-Output "  -Help                   Show this help message"
        return
    }

    if (-not (Test-Path -Path $Dir -PathType Container)) {
        throw "The specified directory does not exist."
    }

    if ($Action -notin @("plan", "apply", "destroy", "import")) {
        throw "Invalid action. Use 'plan', 'apply', 'destroy', or 'import'."
    }

    $varFiles = @(Get-ChildItem -LiteralPath $Dir -Filter *.tfvars -File | Sort-Object Name | ForEach-Object { "-var-file=$($_.FullName)" })

    if ($varFiles.Count -eq 0) {
        throw "No .tfvars files found in the specified directory."
    }

    Write-Output "Initializing Terraform..."
    terraform init -input=false
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform initialization failed."
    }

    Write-Output "Selecting the workspace: $Workspace"
    terraform workspace select -or-create $Workspace
    if ($LASTEXITCODE -ne 0) {
        throw "Workspace selection failed."
    }

    Write-Output "Validating Terraform configuration..."
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validation failed."
    }

    $terraformArgs = @($Action) + $varFiles + $TerraformArguments

    if ($Action -eq "import") {
        if (-not $ResourceAddress -or -not $ResourceId) {
            throw "For 'import' action, both resource address and resource ID must be provided."
        }
        $terraformArgs += @($ResourceAddress, $ResourceId)
    } elseif ($Auto -eq "auto" -and ($Action -eq "apply" -or $Action -eq "destroy")) {
        $terraformArgs += "-auto-approve"
    }

    Write-Output "Executing Terraform $Action in workspace $Workspace with $($varFiles.Count) var-files."
    & terraform @terraformArgs
    if ($LASTEXITCODE -ne 0) { throw "Terraform $Action failed (exit $LASTEXITCODE)." }
}

# Usage examples:
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "plan" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "apply" -Auto "auto" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "destroy" -Auto "auto" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "import" -ResourceAddress "resource_address" -ResourceId "resource_id" -Workspace "workspace"