Write-Host "Reading configuration..."
Import-Module powershell-yaml
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$packages = $config.packages

function Uninstall-AppXPackages {
    param($config)

    foreach ($pkg in $config.pkgs) {
        $foundPkg = Get-AppxPackage $($pkg.name)
        if ($foundPkg) {
            Write-Host "Uninstalling $($foundPkg.name) AppX package..."
            Remove-AppxPackage $foundPkg | Out-Null
        }
    }
}

if ($packages.uninstall.appx) { Uninstall-AppXPackages $packages.uninstall.appx }
