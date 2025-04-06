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
        Write-Output "  -Help                   Show this help message"
        return
    }

    if (-not (Test-Path -Path $Dir -PathType Container)) {
        Write-Error "The specified directory does not exist."
        return
    }

    if ($Action -notin @("plan", "apply", "destroy", "import")) {
        Write-Error "Invalid action. Use 'plan', 'apply', 'destroy', or 'import'."
        return
    }

    $varFiles = Get-ChildItem -Path $Dir -Filter *.tfvars | ForEach-Object { "--var-file $_" }

    if ($varFiles.Count -eq 0) {
        Write-Error "No .tfvars files found in the specified directory."
        return
    }

    Write-Output "Initializing Terraform..."
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform initialization failed."
        return
    }

    Write-Output "Selecting the workspace: $Workspace"
    terraform workspace select -or-create $Workspace
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Workspace selection failed."
        return
    }

    Write-Output "Validating Terraform configuration..."
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform validation failed."
        return
    }

    $command = "terraform $Action $($varFiles -join ' ')"

    if ($Action -eq "import") {
        if (-not $ResourceAddress -or -not $ResourceId) {
            Write-Error "For 'import' action, both resource address and resource ID must be provided."
            return
        }
        $command = "$command $ResourceAddress $ResourceId"
    } elseif ($Auto -eq "auto" -and ($Action -eq "apply" -or $Action -eq "destroy")) {
        $command = "$command -auto-approve"
    }

    Write-Output "Executing: $command"
    Invoke-Expression $command
}

# Usage examples:
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "plan" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "apply" -Auto "auto" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "destroy" -Auto "auto" -Workspace "workspace"
# Terraform-WithVarFiles -Dir "/path/to/directory" -Action "import" -ResourceAddress "resource_address" -ResourceId "resource_id" -Workspace "workspace"