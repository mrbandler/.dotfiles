Write-Host "Reading configuration..."
Import-Module powershell-yaml
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "../../config.yml"
$config = Get-Content $configPath -Raw | ConvertFrom-Yaml
$packages = $config.packages

function Add-RegFile {
    param($regFile)
    if (Test-Path $regFile) {
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s", "`"$regFile`"" -Verb RunAs -Wait | Out-Null
        Write-Host "Applied registry file: $regFile"
    }
    else {
        Write-Host "Registry file not found: $regFile"
    }
}

function Install-ChocolateyPackages {
    param($config)

    Write-Host "Installing Chocolatey packages..."
    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing '$($pkg.name)' package..."
        choco install $pkg.name -y | Out-Null
    }
}

function Install-ScoopPackages {
    param($config)

    Write-Host "Installing scoop packages..."

    foreach ($bucket in $config.buckets) {
        Write-Host "Adding '$bucket' bucket..."
        scoop bucket add $bucket | Out-Null
    }

    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing '$($pkg.name)' package..."
        scoop install $pkg.name | Out-Null

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

    Write-Host "Installing winget packages..."
    foreach ($pkg in $config.pkgs) {
        Write-Host "Installing '$($pkg.name)' package..."
        winget install -e --id $pkg.id --accept-package-agreements --accept-source-agreements | Out-Null
    }
}

function Install-DownloadPackages {
    param($config)

    Write-Host "Installing download packages..."

    $tmpDownloadDir = Join-Path -Path $env:TEMP -ChildPath "dotfiles"
    New-Item -ItemType Directory -Force -Path $tmpDownloadDir | Out-Null
    Write-Host "Downloading packages to: $tmpDownloadDir"

    foreach ($pkg in $config.pkgs) {
        if ($pkg.if) {
            $result = Invoke-Expression $pkg.if
            if (-not $result) {
                continue
            }
        }

        Write-Host "Installing '$($pkg.name)' package..."
        if (-not $pkg.zip -or $pkg.zip -eq $false) {
            $installer = Join-Path -Path $tmpDownloadDir -ChildPath $pkg.installer
            Invoke-WebRequest -Uri $pkg.url -OutFile $installer
            Install-Setup -Path $installer -Args $pkg.args
            Remove-Item -Path $installer -Force
        }
        else {
            $downloadPath = Join-Path -Path $tmpDownloadDir -ChildPath $pkg.artifact
            Invoke-WebRequest -Uri $pkg.url -OutFile $downloadPath

            $zipWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($pkg.artifact)
            $extractPath = Join-Path -Path $tmpDownloadDir -ChildPath $zipWithoutExtension
            Expand-Archive -LiteralPath $downloadPath -DestinationPath $extractPath -Force
            $installer = Get-ChildItem -Path $extractPath -Filter $pkg.installer -Recurse | Select-Object -ExpandProperty FullName -First 1

            Install-Setup -Path $installer -Args $pkg.args
            Remove-Item -Path $downloadPath -Recurse -Force
            Remove-Item -Path $extractPath -Recurse -Force
        }
    }

    Remove-Item -Path $tmpDownloadDir -Recurse -Force
}

function Install-LocalPackages {
    param($config)

    Write-Host "Installing local packages..."

    foreach ($pkg in $config.pkgs) {
        if ($pkg.if) {
            $result = Invoke-Expression $pkg.if
            if (-not $result) {
                continue
            }
        }

        Write-Host "Installing '$($pkg.name)' package..."
        $configDir = [System.IO.Path]::GetDirectoryName($configPath)
        $installer = Join-Path -Path $configDir -ChildPath $pkg.path

        Install-Setup -Path $installer -Args $pkg.args
    }
}

function Install-Setup() {
    param(
        [string]$Path,
        [string]$Args
    )

    $extension = [System.IO.Path]::GetExtension($Path)
    switch ($extension) {
        ".msi" {
            if (-not $Args -or $Args.Count -eq 0) {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$Path`"" -Wait -NoNewWindow
            }
            else {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$Path`" $Args" -Wait -NoNewWindow
            }
        }
        ".exe" {
            if (-not $Args -or $Args.Count -eq 0) {
                Start-Process -FilePath $path -Wait -NoNewWindow
            }
            else {
                Start-Process -FilePath $path -ArgumentList $Args -Wait -NoNewWindow
            }
        }
        default {
        }
    }
}

if ($packages.install.winget) { Install-WingetPackages $packages.install.winget }
if ($packages.install.choco) { Install-ChocolateyPackages $packages.install.choco }
if ($packages.install.scoop) { Install-ScoopPackages $packages.install.scoop }
if ($packages.install.downloads) { Install-DownloadPackages $packages.install.downloads }
if ($packages.install.local) { Install-LocalPackages $packages.install.local }
