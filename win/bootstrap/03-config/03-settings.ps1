Import-Module powershell-yaml

$themePath = Join-Path -Path $PSScriptRoot -ChildPath "../../theme.deskthemepack"
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$settings = $config.settings

Write-Host "Installing theme..."
Invoke-Item -Path $themePath

Write-Host "Applying registry settings..."
foreach ($reg in $settings.registry) {
    Write-Host "Applying: $($reg.desc)"
    Set-ItemProperty -Path $reg.path -Name $reg.name -Value $reg.value -Type $reg.type -Force
}
Write-Host "Restarting Explorer to apply changes..."
Stop-Process -Name explorer -Force

Write-Host "Applying network settings..."
$dns = $settings.network.dns
$adapters = Get-NetAdapter
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceAlias $($adapter.Name) -ServerAddresses ($dns.primary.v4, $dns.secondary.v4, $dns.primary.v6, $dns.secondary.v6) -ErrorAction SilentlyContinue
}
