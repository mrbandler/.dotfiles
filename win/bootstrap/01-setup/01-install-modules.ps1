Write-Host "Configuring repos..."
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

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
        Write-Host "Installing module '$($modulen.name)'"
        Install-Module -Name $module.name -Scope CurrentUser -SkipPublisherCheck
        if ($module.install) {
            Invoke-Expression $module.install
        }
    }
    else {
        Write-Host "Module '$($module.name)' already installed"
    }
}