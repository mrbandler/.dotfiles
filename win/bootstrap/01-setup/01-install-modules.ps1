$modulesToInstall = @(
    'PSDotFiles',
    'winget-install',
    'powershell-yaml',
    'Terminal-Icons'
)

Write-Host "Configuring repos..."
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Write-Host "Installing modules..."
foreach ($module in $modulesToInstall) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -SkipPublisherCheck
        Write-Host "Installed module: $module"
    }
    else {
        Write-Host "Module already installed: $module"
    }
}

Install-Script winget-install -Force
