# Check if the script is running as an administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Reconstruct the script path and arguments if any
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

    # Relaunch the script with administrator rights
    Start-Process PowerShell.exe -ArgumentList $arguments -Verb RunAs
    exit
}

$bootstrapDir = Join-Path -Path $PSScriptRoot -ChildPath "bootstrap"
$phases = Get-ChildItem -Path $bootstrapDir -Directory | Sort-Object Name

Write-Host "Starting bootstrapping process...`n"
foreach ($phase in $phases) {
    Write-Host "Starting $($phase.Name) phase..."

    # Get all .ps1 files in the current phase directory, sorted by name
    $scripts = Get-ChildItem -Path $phase.FullName -Filter "*.ps1" | Sort-Object Name

    # Execute each script in the current phase
    foreach ($script in $scripts) {
        $scriptPath = $script.FullName
        Write-Host "Running: $phase/$script"
        . $scriptPath
    }
    Write-Host "$($phase.Name) phase complete.`n"
}
Write-Host "Bootstrapping complete. Please restart now for changes to take effect."
