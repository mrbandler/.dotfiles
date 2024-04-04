Import-Module powershell-yaml
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$packages = $config.packages

function Add-RegFile {
    param($regFile)
    if (Test-Path $regFile) {
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s", "`"$regFile`"" -Verb RunAs -Wait
        Write-Host "Applied registry file: $regFile"
    }
    else {
        Write-Host "Registry file not found: $regFile"
    }
}

function Install-ChocolateyPackages {
    param($config)

    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing Chocolatey package: $($pkg.name)"
        choco install $pkg.name -y
    }
}

function Install-ScoopPackages {
    param($config)

    foreach ($bucket in $config.buckets) {
        Write-Host "Adding Scoop bucket: $bucket"
        scoop bucket add $bucket
    }

    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing Scoop package: $($pkg.name)"
        scoop install $pkg.name

        if ($pkg.features -and $pkg.features.Count -gt 0) {
            $prefix = scoop prefix $pkg.name
            foreach ($feature in $pkg.features) {
                $featureFile = Join-Path -Path $prefix -ChildPath $feature
                if ($featureFile -like "*.reg") { Add-RegFile $featureFile }
                else { Invoke-Item $featureFile }
            }
        }
    }
}

function Install-WingetPackages {
    param($config)

    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing winget package: $($pkg.name)"
        winget install -e --id $pkg.name --accept-package-agreements --accept-source-agreements
    }
}

if ($packages.install.winget) { Install-WingetPackages $packages.install.winget }
if ($packages.install.choco) { Install-ChocolateyPackages $packages.install.choco }
if ($packages.install.scoop) { Install-ScoopPackages $packages.install.scoop }
