# Ensure the script is running as an Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as an Administrator."
    exit
}

# Check and install/update Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey is installed. Checking for updates..."
    choco upgrade chocolatey -y
}
else {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Check and install/update Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop is installed. Checking for updates..."
    scoop update
}
else {
    Write-Host "Installing Scoop..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    # Add Scoop to PATH
    $env:Path += ";$env:USERPROFILE\scoop\shims"
}

# Check and install/update winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Winget is installed. Checking for updates..."
    winget upgrade --id Microsoft.AppInstaller --silent
}
else {
    Write-Host "Installing winget..."
    $apiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $latestRelease = Invoke-RestMethod -Uri $apiUrl -Headers @{Accept = "application/vnd.github.v3+json" }
    $msixBundleAsset = $latestRelease.assets | Where-Object { $_.name -like "*.msixbundle" }
    $downloadPath = Join-Path -Path $env:TEMP -ChildPath $msixBundleAsset.name
    Invoke-WebRequest -Uri $msixBundleAsset.browser_download_url -OutFile $downloadPath
    Add-AppxPackage -Path $downloadPath
    Remove-Item -Path $downloadPath -Force
}
