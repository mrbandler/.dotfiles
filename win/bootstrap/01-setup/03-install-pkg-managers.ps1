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
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    # Add Scoop to PATH
    $env:Path += ";$env:USERPROFILE\scoop\shims"
}

# Check and install/update winget
Write-Host "Installing winget..."
&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
