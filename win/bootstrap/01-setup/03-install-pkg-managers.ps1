# Check and install/update Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey is installed. Checking for updates..."
    choco upgrade chocolatey -y | Out-Null
}
else {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
}

# Check and install/update Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop is installed. Checking for updates..."
    scoop update | Out-Null
}
else {
    Write-Host "Installing Scoop..."
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin" | Out-Null
    # Add Scoop to PATH
    $env:Path += ";$env:USERPROFILE\scoop\shims"
    scoop install git | Out-Null
}

# Install winget and change to Microsoft Store enabled region.
Write-Host "Switching to Mircosoft Store enabled region for winget installation..."
Set-ItemProperty -Path "HKCU:\Control Panel\International\Geo" -Name "Name" -Value DE
Set-ItemProperty -Path "HKCU:\Control Panel\International\Geo" -Name "Nation" -Value 94
Write-Host "Installing winget..."
&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
