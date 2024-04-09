Write-Host "Configuring repos..."
Install-PackageProvider -Name "NuGet" -Force | Out-Null
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted | Out-Null

Write-Host "Installing YAML module to read configuration..."
Install-Module -Name "powershell-yaml" -Scope CurrentUser -SkipPublisherCheck

Write-Host "Reading configuration..."
Import-Module powershell-yaml
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$modules = $config.modules

Write-Host "Installing modules..."
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing '$($module.name)' module..."
        Install-Module -Name $module.name -Scope CurrentUser -SkipPublisherCheck | Out-Null
        if ($module.install) {
            Invoke-Expression $module.install | Out-Null
        }
    }
    else {
        Write-Host "Module '$($module.name)' already installed"
    }
}