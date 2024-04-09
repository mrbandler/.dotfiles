Write-Host "Reading configuration..."
Import-Module powershell-yaml
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$features = $config.features

Write-Host "Enabling features..."
foreach ($feature in $features) {
    Write-Host "Enabling '$($feature.name)' feature..."
    Enable-WindowsOptionalFeature -Online -FeatureName $feature.name -All -NoRestart | Out-Null
}